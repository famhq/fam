z = require 'zorium'
_map = require 'lodash/map'
_filter = require 'lodash/filter'
_last = require 'lodash/last'
_isEmpty = require 'lodash/isEmpty'
_debounce = require 'lodash/debounce'
_flatten = require 'lodash/flatten'
_uniqBy = require 'lodash/uniqBy'
_pick = require 'lodash/pick'
Environment = require 'clay-environment'
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject
RxReplaySubject = require('rxjs/ReplaySubject').ReplaySubject
RxObservable = require('rxjs/Observable').Observable
require 'rxjs/add/observable/of'
require 'rxjs/add/observable/combineLatest'
require 'rxjs/add/observable/merge'
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
  require './index.styl'

# we don't give immediate feedback for post (waits for cache invalidation and
# refetch), don't want users to post twice
MAX_POST_MESSAGE_LOAD_MS = 5000 # 5s
MAX_CHARACTERS = 500
MAX_LINES = 20
RESIZE_THROTTLE_MS = 150
FIVE_MINUTES_MS = 60 * 5 * 1000
SCROLL_MESSAGE_LOAD_COUNT = 20

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

    conversationAndMe = RxObservable.combineLatest(
      @conversation
      me
      (vals...) -> vals
    )

    # not putting in state because re-render is too slow on type
    @message = new RxBehaviorSubject ''
    @resetMessageBatches = new RxBehaviorSubject null

    lastConversationId = null
    @isLoadingMore

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
        {isScrolledBottom, isLoaded} = @state.getValue()
        if isScrolledBottom and isLoaded
          setTimeout =>
            @scrollToBottom {
              isSmooth: isLoaded
            }
          , 0
        else if not isLoaded
          maxTries = 5 # 1s
          scrollBottomIfScroll = (attempt = 0) =>
            scrolled = @scrollToBottom {
              isSmooth: isLoaded and attempt is 0
            }
            if not scrolled and attempt < maxTries
              setTimeout ->
                scrollBottomIfScroll attempt + 1
              , 200
            else
              @$$loadingSpinner?.style.display = 'none'
              @state.set isLoaded: true

          scrollBottomIfScroll()

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
      @overlay$
      @inputTranslateY
      @conversation
      onPost: @postMessage
      onResize: @onResize
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

    @debouncedOnResize = _debounce @onResize
    , RESIZE_THROTTLE_MS

    messageBatchesAndMe = RxObservable.combineLatest(
      messageBatches
      me
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
      isScrolledBottom: true

      messageBatches: messageBatchesAndMe.map ([messageBatches, me]) =>
        if messageBatches
          _map messageBatches, (messages) =>
            prevMessage = null
            _filter _map messages, (message) =>
              unless message
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
    @debouncedScrollListener = _debounce @scrollListener, 20, {
      maxWait: 100
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

    @scrollToBottom()
    window?.addEventListener 'resize', @debouncedOnResize

  beforeUnmount: =>
    super()

    {conversation} = @state.getValue()
    if conversation
      @model.chatMessage.unsubscribeByConversationId conversation?.id

    @disposable.unsubscribe()

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

    window?.removeEventListener 'resize', @debouncedOnResize

  getMessagesStream: (maxTimeUuid) =>
    @conversation.switchMap (conversation) =>
      if conversation
        @model.chatMessage.getAllByConversationId conversation.id, {
          maxTimeUuid
          isStreamed: not maxTimeUuid # don't stream old message batches
        }
      else
        RxObservable.of null

  scrollListener: =>
    {isScrolledBottom} = @state.getValue()
    scrollTop = @$$messages.scrollTop
    scrollHeight = @$$messages.scrollHeight
    offsetHeight = @$$messages.offsetHeight

    if @lastScrollTop > 50 and scrollTop < @lastScrollTop
      @onScrollUp?()
    else if @lastScrollTop > 50 and scrollTop > @lastScrollTop
      @onScrollDown?()

    if scrollHeight - scrollTop - offsetHeight < 10
      unless isScrolledBottom
        @state.set isScrolledBottom: true
    else
      if isScrolledBottom
        @state.set isScrolledBottom: false

    # keep simple so we don't have to debounce / throttle
    if @isLoadingMore
      return

    if scrollTop is 0
      @loadMore()

    @lastScrollTop = scrollTop

  loadMore: =>
    @isLoadingMore = true

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
      @isLoadingMore = false
      @$$loadingSpinner.style.display = 'none'

      if $$firstMessageBatch?.scrollIntoView # doesn't work on ios
        $$firstMessageBatch?.scrollIntoView?() # works on android
        setTimeout =>  # works on ios, but has flash
          $$firstMessageBatch?.scrollIntoView?()
          @lastScrollTop = null
        , 0
      else
        setTimeout =>
          @$$messages.scrollTop =
            @$$messages.scrollHeight - previousScrollHeight
          @lastScrollTop = null
        , 0


  prependMessagesStream: (messagesStream) =>
    @messageBatchesStreamCache = [messagesStream].concat(
      @messageBatchesStreamCache
    )
    @messageBatchesStreams.next RxObservable.combineLatest(
      @messageBatchesStreamCache, (messageBatches...) ->
        messageBatches
    )

  scrollToBottom: ({isSmooth} = {}) =>
    $messageArr = @$$el?.querySelectorAll('.z-conversation-message')
    $$lastMessage = _last $messageArr
    isMobile = Environment.isMobile()
    if not @scrollYOnly and $$lastMessage?.scrollIntoView and not isMobile
      try
        $$lastMessage.scrollIntoView {
          behavior: if isSmooth then 'smooth' else 'instant'
        }
        scrolled = true
    else if @$$messages
      scrollHeight = @$$messages.scrollHeight
      offsetHeight = @$$messages.offsetHeight
      scrolled = scrollHeight > offsetHeight
      @$$messages.scrollTop = scrollHeight - offsetHeight
      @lastScrollTop = null
    return scrolled

  onResize: =>
    {isScrolledBottom} = @state.getValue()
    if isScrolledBottom
      setImmediate =>
        @scrollToBottom {isSmooth: true}

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
      unless localStorage?['isPushTokenStored']
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
    {me, isLoading, isLoadingMore, message, isTextareaFocused, isLoaded,
      messageBatches, conversation, group, isScrolledBottom, inputTranslateY,
      groupUser, isJoinLoading, hasBottomBar} = @state.getValue()

    z '.z-conversation', {
      className: z.classKebab {hasBottomBar}
    },
      # hide messages until loaded to prevent showing the scrolling
      z '.messages', {
        key: 'conversation-messages'
        style:
          transform: "translateY(#{inputTranslateY}px)"
      },
        [
          # toggled with vanilla js (non-vdom for perf)
          z '.loading', {
            key: 'conversation-messages-loading-spinner'
          },
            @$loadingSpinner
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
        ]

      if group and groupUser and not groupUser.userId
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
