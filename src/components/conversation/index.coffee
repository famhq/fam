z = require 'zorium'
_map = require 'lodash/map'
_filter = require 'lodash/filter'
_last = require 'lodash/last'
_isEmpty = require 'lodash/isEmpty'
_debounce = require 'lodash/debounce'
_flatten = require 'lodash/flatten'
_uniqBy = require 'lodash/uniqBy'
_pick = require 'lodash/pick'
Environment = require '../../services/environment'
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject
RxReplaySubject = require('rxjs/ReplaySubject').ReplaySubject
RxObservable = require('rxjs/Observable').Observable
require 'rxjs/add/observable/of'
require 'rxjs/add/observable/combineLatest'
require 'rxjs/add/observable/merge'
require 'rxjs/add/observable/never'
require 'rxjs/add/operator/share'
require 'rxjs/add/operator/map'
require 'rxjs/add/operator/switchMap'

Spinner = require '../spinner'
Base = require '../base'
FormattedText = require '../formatted_text'
PrimaryButton = require '../primary_button'
ConversationInput = require '../conversation_input'
ConversationMessage = require '../conversation_message'
config = require '../../config'

if window?
  IScroll = require 'iscroll/build/iscroll-lite-snap.js'
  require './index.styl'

# we don't give immediate feedback for post (waits for cache invalidation and
# refetch), don't want users to post twice
MAX_POST_MESSAGE_LOAD_MS = 5000 # 5s
MAX_CHARACTERS = 500
MAX_LINES = 20
SCROLL_MAX_WAIT_MS = 100
FIVE_MINUTES_MS = 60 * 5 * 1000
SCROLL_MESSAGE_LOAD_COUNT = 20
DELAY_BETWEEN_LOAD_MORE_MS = 500

# TODO: move all the scrolling stuff into a separate component

module.exports = class Conversation extends Base
  constructor: (options) ->
    {@model, @router, @error, @conversation, isActive, @overlay$, toggleIScroll,
      selectedProfileDialogUser, @scrollYOnly, @isGroup, isLoading, @onScrollUp,
      @onScrollDown, hasBottomBar, group} = options

    isLoading ?= new RxBehaviorSubject false
    @isPostLoading = new RxBehaviorSubject false
    isTextareaFocused = new RxBehaviorSubject false
    isActive ?= new RxBehaviorSubject false
    me = @model.user.getMe()
    @conversation ?= new RxBehaviorSubject null
    @error = new RxBehaviorSubject null

    @isPaused = new RxBehaviorSubject false

    conversationAndMe = RxObservable.combineLatest(
      @conversation
      me
      (vals...) -> vals
    )

    # not putting in state because re-render is too slow on type
    @message = new RxBehaviorSubject ''
    @resetMessageBatches = new RxBehaviorSubject null

    lastConversationId = null
    @canLoadMore = true

    loadedMessages = conversationAndMe.switchMap (resp) =>
      [conversation, me] = resp

      if lastConversationId isnt conversation?.id
        isLoading.next true

      lastConversationId = conversation?.id

      @messageBatchesStreams = new RxReplaySubject(1)
      @messageBatchesStreamCache = []
      @prependMessagesStream @getMessagesStream()

      @messageBatchesStreams.switch()
      .map (messageBatches) =>
        isLoading.next false
        @$$loadingSpinner?.style.display = 'none'
        @state.set isLoaded: true
        @iScrollContainer?.refresh()
        messageBatches
      .catch (err) ->
        console.log err
        RxObservable.of []
    .share()

    messageBatches = RxObservable.merge @resetMessageBatches, loadedMessages

    @groupUser = if group \
                then group.map (group) -> group?.meGroupUser
                else RxObservable.of null

    groupUserAndConversation = RxObservable.combineLatest(
      @groupUser, @conversation, (vals...) -> vals
    )

    @inputTranslateY = new RxReplaySubject 1

    @$loadingSpinner = new Spinner()
    @$joinButton = new PrimaryButton()
    @$conversationInput = new ConversationInput {
      @model
      @router
      @message
      isTextareaFocused
      toggleIScroll
      @isPostLoading
      @overlay$
      @inputTranslateY
      @conversation
      group: group
      meGroupUser: @groupUser
      onPost: @postMessage
      allowedPanels: groupUserAndConversation.map ([groupUser, conversation]) =>
        if conversation?.groupId
          panels = ['text', 'stickers']
          meGroupUser = groupUser
          permissions = ['sendImage']
          channelId = conversation.id
          hasImagePermission = @model.groupUser.hasPermission {
            meGroupUser, permissions, channelId
          }
          if hasImagePermission
            panels = panels.concat ['image', 'gifs']

          permissions = ['sendAddon']
          hasAddonPermission = @model.groupUser.hasPermission {
            meGroupUser, permissions, channelId
          }
          if hasAddonPermission
            panels = panels.concat ['addons']

          panels
        else
          ['text', 'stickers', 'image', 'gifs', 'addons']
    }

    messageBatchesAndMeAndBlockedUserIds = RxObservable.combineLatest(
      messageBatches
      me
      @model.userBlock.getAllIds()
      (vals...) -> vals
    )

    @state = z.state
      me: me
      isLoading: isLoading
      isActive: isActive
      isTextareaFocused: isTextareaFocused
      isPostLoading: @isPostLoading
      hasBottomBar: hasBottomBar
      error: null
      conversation: @conversation
      inputTranslateY: @inputTranslateY.switch()
      group: group
      groupUser: @groupUser
      isJoinLoading: false
      isLoaded: false

      messageBatches: messageBatchesAndMeAndBlockedUserIds
      .map ([messageBatches, me, blockedUserIds]) =>
        if messageBatches
          _map messageBatches, (messages) =>
            prevMessage = null
            _filter _map messages, (message) =>
              unless message
                return
              isBlocked = @model.userBlock.isBlocked(
                blockedUserIds, message?.userId
              )
              if isBlocked
                return
              isRecent = new Date(message?.time) - new Date(prevMessage?.time) <
                          FIVE_MINUTES_MS
              isGrouped = message.userId is prevMessage?.userId and isRecent
              isMe = message.userId is me.id
              id = message.id or message.clientId
              # if we get this in conversationmessasge, there's a flicker for
              # state to get set
              bodyCacheKey = "#{message.clientId}:text"
              messageCacheKey = "#{id}:#{message.lastUpdateTime}:message"

              $body = @getCached$ bodyCacheKey, FormattedText, {
                @model, @router, text: message.body, selectedProfileDialogUser
                mentionedUsers: message.mentionedUsers
                useThumbnails: true
              }
              $el = @getCached$ messageCacheKey, ConversationMessage, {
                message, @model, @router, @overlay$, isMe,
                isGrouped, selectedProfileDialogUser, $body,
                @messageBatchesStreams
              }
              prevMessage = message
              {$el, isGrouped, timeUuid: message.timeUuid, id}

  afterMount: (@$$el) =>
    @$$loadingSpinner = @$$el?.querySelector('.loading')
    @$$messages = @$$el?.querySelector('.messages')
    # use iscroll on ios...
    if Environment.isiOS {userAgent: navigator.userAgent}
      checkIsReady = =>
        @$$messages = @$$el?.querySelector('.messages')
        if @$$messages and @$$messages.clientWidth
          @initIScroll @$$messages
        else
          setTimeout checkIsReady, 1000

      checkIsReady()
    else
      @debouncedScrollListener = _debounce @scrollListener, 20, {
        maxWait: SCROLL_MAX_WAIT_MS
        trailing: true
      }
      @$$messages?.addEventListener 'scroll', @debouncedScrollListener

    prevConversation = null
    @disposable = @conversation.subscribe (newConversation) =>
      @model.portal.call 'push.setContextId', {
        contextId: newConversation?.id
      }
      # server doesn't need to push us new updates
      if prevConversation and prevConversation.id isnt newConversation.id
        @model.chatMessage.unsubscribeByConversationId prevConversation.id

      prevConversation = newConversation

  beforeUnmount: =>
    super()

    {conversation} = @state.getValue()
    if conversation
      @model.chatMessage.unsubscribeByConversationId conversation?.id

    @disposable.unsubscribe()

    @isPaused.next false
    @iScrollContainer?.destroy()

    @$$messages?.removeEventListener 'scroll', @debouncedScrollListener
    @$$loadingSpinner?.style.display = 'block'

    # to update conversations page, etc...
    # TODO: should update via streaming or just ignore cache?
    unless @isGroup
    #   # race condition without timeout.
    #   # new page tries to get new exoid stuff, but it gets cleared at same
    #   # exact time. caused an issue of leaving event page back to home,
    #   # and home had no responses / empty streams / unobserved streams
    #   # for group data
      setImmediate =>
        @model.exoid.invalidateAll()
    @resetMessageBatches.next [[]]
    setTimeout =>
      @state.set isLoaded: false
    , 0

    @model.portal.call 'push.setContextId', {
      contextId: 'empty'
    }


    # hacky: without this, when leaving a conversation, changing browser tabs,
    # then coming back and going back to conversation, the client-created
    # messages will show for a split-second before the rest load in.
    # but WITH this, leaving a conversation and coming back to it sometimes
    # causes new messages to not post FIXME FIXME
    # @model.chatMessage.resetClientChangesStream conversation?.id

  initIScroll: =>
    @iScrollContainer = new IScroll @$$messages, {
      scrollX: false
      scrollY: true
      # eventPassthrough: true
      click: true
      bounce: false
      deceleration: 0.0006
      useTransition: false
      isReversed: true
    }

    # the scroll listener in IScroll (iscroll-probe.js) is really slow
    isScrolling = false
    @iScrollContainer.on 'scrollStart', =>
      isScrolling = true
      update = =>
        @iScrollListener()
        if isScrolling
          window.requestAnimationFrame update
      update()

    @iScrollContainer.on 'scrollEnd', =>
      isScrolling = false

  getMessagesStream: (maxTimeUuid) =>
    conversationAndIsPaused = RxObservable.combineLatest(
      @conversation
      @isPaused
      (vals...) -> vals
    )
    # TODO: might be better to have the isPaused somewhere else.
    # have 1 obs with all messages, and 1 that's paused, and get the diff
    # in count to show how many new messages
    conversationAndIsPaused.switchMap ([conversation, isPaused]) =>
      if isPaused and not maxTimeUuid
        RxObservable.never()
      else if conversation
        @model.chatMessage.getAllByConversationId conversation.id, {
          maxTimeUuid
          isStreamed: not maxTimeUuid # don't stream old message batches
        }
      else
        RxObservable.of null

  iScrollListener: =>
    isBottom = @iScrollContainer.y is 0
    isTop = @iScrollContainer.y is @iScrollContainer.maxScrollY

    if isBottom and @isPaused.getValue()
      @isPaused.next false
    else if isTop and @isPaused.getValue()
      @isPaused.next false
    else if not @isPaused.getValue()
      @isPaused.next true

    maxScrollY = @iScrollContainer.maxScrollY or @$$messages.offsetHeight
    scrollY = maxScrollY - @iScrollContainer.y
    @handleScroll Math.abs(scrollY), @iScrollContainer.directionY

  scrollListener: =>
    scrollTop = @$$messages.scrollTop
    scrollHeight = @$$messages.scrollHeight
    offsetHeight = @$$messages.offsetHeight
    fromBottom = scrollHeight - offsetHeight - scrollTop


    # safari treats these different with flex-direction: column-reverse
    isSafari = navigator.userAgent?.match /^((?!chrome|android).)*safari/i
    if isSafari
      # scrollTopTmp = scrollTop
      # scrollTop = fromBottom
      fromBottom = Math.abs scrollTop
      scrollTop = scrollTop + (scrollHeight - offsetHeight)

    direction = if scrollTop < @lastScrollY \
                then 1
                else if scrollTop > @lastScrollY
                then -1
                else 0

    @handleScroll scrollTop, direction

  handleScroll: (scrollY, direction) =>
    notNearTop = scrollY > 50

    if notNearTop and direction is 1
      @onScrollUp?()
    else if notNearTop and direction is -1
      @onScrollDown?()

    # a little slow on iOS with the bounce animation, but if <=, it flickers
    if @canLoadMore and scrollY is 0
      @loadMore()

    @lastScrollY = scrollY

  loadMore: =>
    @canLoadMore = false

    # don't re-render or set state since it's slow with all of the conversation
    # messages
    @$$loadingSpinner.style.display = 'block'

    {messageBatches} = @state.getValue()
    maxTimeUuid = messageBatches?[0]?[0]?.timeUuid
    messagesStream = @getMessagesStream maxTimeUuid
    @prependMessagesStream messagesStream

    $$firstMessageBatch = @$$el?.querySelector('.message-batch')
    previousScrollHeight = @$$messages.scrollHeight

    messagesStream.take(1).toPromise()
    .then =>
      setTimeout (=> @canLoadMore = true), DELAY_BETWEEN_LOAD_MORE_MS

      @$$loadingSpinner.style.display = 'none'


  prependMessagesStream: (messagesStream) =>
    @messageBatchesStreamCache = [messagesStream].concat(
      @messageBatchesStreamCache
    )
    @messageBatchesStreams.next RxObservable.combineLatest(
      @messageBatchesStreamCache, (messageBatches...) ->
        messageBatches
    )

  scrollToBottom: =>
    @$$messages.scrollTop = 0

  postMessage: =>
    {me, conversation, isPostLoading} = @state.getValue()

    messageBody = @message.getValue()

    if not isPostLoading and messageBody
      @isPostLoading.next true

      type = if conversation?.group?.type is 'public' \
             then 'public'
             else if conversation?.groupId
             then 'group'
             else 'private'
      ga? 'send', 'event', 'chat_message', 'post', type

      @model.chatMessage.create {
        body: messageBody
        conversationId: conversation?.id
        userId: me?.id
      }, {user: me, time: Date.now()}
      .then (response) =>
        # @model.user.emit('chatMessage').catch log.error
        @isPostLoading.next false
        response
      .catch =>
        @isPostLoading.next false
    else
      Promise.resolve null # reject here?

  join: =>
    {me, group} = @state.getValue()
    @state.set isJoinLoading: true

    @model.signInDialog.openIfGuest me
    .then =>
      unless @model.cookie.get 'isPushTokenStored'
        @model.pushNotificationSheet.open()
      Promise.all _filter [
        @model.group.joinById group.id
        if group.star
          @model.userFollower.followByUserId group.star?.user?.id
      ]
      .then =>
        # just in case...
        setTimeout =>
          @state.set isJoinLoading: false
        , 1000
        @groupUser.take(1).subscribe =>
          @state.set isJoinLoading: false
    .catch =>
      @state.set isJoinLoading: false

  render: =>
    {me, isLoading, message, isTextareaFocused, isLoaded,
      messageBatches, conversation, group, inputTranslateY,
      groupUser, isJoinLoading, hasBottomBar} = @state.getValue()

    z '.z-conversation', {
      className: z.classKebab {hasBottomBar}
    },
      # toggled with vanilla js (non-vdom for perf)
      z '.loading', {
        key: 'conversation-messages-loading-spinner'
      },
        @$loadingSpinner
      # hide messages until loaded to prevent showing the scrolling
      z '.messages', {
        key: 'conversation-messages'
        style:
          transform: "translateY(#{inputTranslateY}px)"
      },
        z '.messages-inner',
          if messageBatches and not isLoading
            _map messageBatches, (messageBatch) ->
              z '.message-batch', {
                className: z.classKebab {isLoaded}
                key: "message-batch-#{messageBatch?[0]?.id}"
              },
                _map messageBatch, ({$el, isGrouped}, i) ->
                  [
                      if i and not isGrouped
                        z '.divider'
                      z $el, {isTextareaFocused}
                  ]

      if conversation?.groupId and groupUser and not groupUser.userId
        z '.bottom.is-gate',
          z '.text',
            @model.l.get 'conversation.joinMessage', {
              replacements:
                name: @model.user.getDisplayName group.star?.user
            }
          z @$joinButton,
            text: if isJoinLoading \
                  then @model.l.get 'general.loading'
                  else @model.l.get 'groupInfo.joinButtonText'
            onclick: @join
      else
        z '.bottom',
          @$conversationInput
