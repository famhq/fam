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
require 'rxjs/add/observable/fromEvent'
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
      selectedProfileDialogUser, @scrollYOnly, @isGroup, isLoading, gameKey,
      group} = options

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
    @messageBatches = new RxBehaviorSubject null

    lastConversationId = null
    @isLoadingMore

    loadedMessages = conversationAndMe.switchMap (resp) =>
      [conversation, me] = resp

      if lastConversationId isnt conversation.id
        isLoading.next true

      lastConversationId = conversation.id

      @messageBatchesStreams = new RxReplaySubject(1)
      @messageBatchesStreamCache = []
      @prependMessagesStream @getMessagesStream()

      @messageBatchesStreams.switch()
      .map (messageBatches) =>
        isLoading.next false
        isLoaded = not _isEmpty @state.getValue().messageBatches
        # HACK: give time for $formattedMessage to resolve
        {isScrolledBottom} = @state.getValue()
        if isScrolledBottom or not isLoaded
          setTimeout =>
            @scrollToBottom {
              isSmooth: isLoaded
            }
          , 100
          unless isLoaded
            setTimeout =>
              @scrollToBottom {
                isSmooth: isLoaded
              }
            , 500

        messageBatches
      .catch (err) ->
        console.log err
        RxObservable.of []
    .share()

    messageBatches = RxObservable.merge @messageBatches, loadedMessages

    @isScrolledBottomStreams = new RxReplaySubject 1
    @isScrolledBottomStreams.next RxObservable.of false
    @inputTranslateY = new RxReplaySubject 1

    @$loadingSpinner = new Spinner()
    @$loadingMoreSpinner = new Spinner()
    @$joinButton = new PrimaryButton()
    @$conversationInput = new ConversationInput {
      @model
      @router
      @message
      isTextareaFocused
      toggleIScroll
      @overlay$
      @inputTranslateY
      gameKey
      onPost: @postMessage
      onResize: @onResize
      allowedPanels: @conversation.map (conversation) ->
        # TODO: conversation-specific settings
        # if conversation.type is 'pm' or not conversation.groupId
        ['text', 'stickers', 'image', 'gifs']
        # else
        #   ['text', 'stickers', 'gifs']
    }

    @debouncedOnResize = _debounce @onResize
    , RESIZE_THROTTLE_MS

    messageBatchesAndMe = RxObservable.combineLatest(
      messageBatches
      me
      (vals...) -> vals
    )

    groupAndMe = RxObservable.combineLatest(
      group or RxObservable.of null
      me
      (vals...) -> vals
    )

    @groupUser = groupAndMe.switchMap ([group, me]) =>
      if group and me
        @model.groupUser.getByGroupIdAndUserId group.id, me.id
        .map (groupUser) ->
          groupUser or false
      else
        RxObservable.of null

    @state = z.state
      me: me
      isLoading: isLoading
      isActive: isActive
      isTextareaFocused: isTextareaFocused
      isPostLoading: @isPostLoading
      error: null
      conversation: @conversation
      inputTranslateY: @inputTranslateY.switch()
      group: group
      groupUser: @groupUser
      isJoinLoading: false
      isLoaded: false
      isScrolledBottom: @isScrolledBottomStreams.switch()

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
              messageCacheKey = "#{id}:text"
              $body = @getCached$ bodyCacheKey, FormattedText, {
                @model, @router, text: message.body
              }
              $el = @getCached$ messageCacheKey, ConversationMessage, {
                message, @model, @router, @overlay$, isMe,
                isGrouped, selectedProfileDialogUser, $body
              }
              prevMessage = message
              {$el, isGrouped, timeUuid: message.timeUuid, id}

  afterMount: (@$$el) =>
    @$$loadingMoreSpinner = @$$el?.querySelector('.loading-more')
    @$$messages = @$$el?.querySelector('.messages')
    # fn is simple enough we don't need to debounce/throttle
    @$$messages?.addEventListener 'scroll', @scrollListener

    @conversation.take(1).subscribe (conversation) =>
      @model.portal.call 'push.setContextId', {
        contextId: conversation?.id
      }
    @scrollToBottom()
    window?.addEventListener 'resize', @debouncedOnResize

    # TODO: make sure this is being disposed of correctly
    # TODO: Merge this with other scroll listener we have
    isScrolledBottom = RxObservable.fromEvent @$$messages, 'scroll'
    .map (e) ->
      e.target.scrollHeight - e.target.scrollTop - e.target.offsetHeight < 10
    @isScrolledBottomStreams.next isScrolledBottom

  beforeUnmount: =>
    {conversation} = @state.getValue()

    @$$messages?.removeEventListener 'scroll', @scrollListener

    # to update conversations page, etc...
    unless @isGroup
      # race condition without timeout.
      # new page tries to get new exoid stuff, but it gets cleared at same
      # exact time. caused an issue of leaving event page back to home,
      # and home had no responses / empty streams / unobserved streams
      # for group data
      setImmediate =>
        @model.exoid.invalidateAll()
    @messageBatches.next [[]]

    @model.portal.call 'push.setContextId', {
      contextId: 'empty'
    }
    @model.chatMessage.resetClientChangesStream conversation?.id
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
    # keep simple so we don't have to debounce / throttle
    if @isLoadingMore
      return

    if @$$messages.scrollTop is 0
      @loadMore()

  loadMore: =>
    @isLoadingMore = true

    # don't re-render or set state since it's slow with all of the conversation
    # messages
    @$$loadingMoreSpinner.style.display = 'block'

    {messageBatches} = @state.getValue()
    maxTimeUuid = messageBatches?[0]?[0]?.timeUuid
    messagesStream = @getMessagesStream maxTimeUuid
    @prependMessagesStream messagesStream

    $$firstMessageBatch = @$$el?.querySelector('.message-batch')

    messagesStream.take(1).toPromise()
    .then =>
      setTimeout => # wait for render
        @isLoadingMore = false
        @$$loadingMoreSpinner.style.display = 'none'
        $$firstMessageBatch?.scrollIntoView?()
      , 0

  prependMessagesStream: (messagesStream) =>
    @messageBatchesStreamCache = [messagesStream].concat(
      @messageBatchesStreamCache
    )
    @messageBatchesStreams.next RxObservable.combineLatest(
      @messageBatchesStreamCache, (messageBatches...) ->
        # _uniqBy _flatten(messageBatches), ({id, clientId}) -> id or clientId
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
    else if @$$messages
      @$$messages.scrollTop = @$$messages.scrollHeight -
                                @$$messages.offsetHeight



    {messageBatches} = @state.getValue()
    @state.set isLoaded: not _isEmpty messageBatches

  onResize: =>
    {isScrolledBottom} = @state.getValue()
    if isScrolledBottom
      setImmediate =>
        @scrollToBottom {isSmooth: true}

  postMessage: =>
    {me, conversation, isPostLoading} = @state.getValue()

    messageBody = @message.getValue()
    # lineBreaks =  messageBody.split(/\r\n|\r|\n/).length
    # if messageBody.length > MAX_CHARACTERS or
    #     lineBreaks > MAX_LINES
    #   @error.next 'Message is too long'
    #   return

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
      .then =>
        # @model.user.emit('chatMessage').catch log.error
        @isPostLoading.next false
      .catch =>
        @isPostLoading.next false

  render: =>
    {me, isLoading, isLoadingMore, message, isTextareaFocused, isLoaded,
      messageBatches, conversation, group, isScrolledBottom, inputTranslateY,
      groupUser, isJoinLoading} = @state.getValue()

    z '.z-conversation',
      z '.g-grid',
        # hide messages until loaded to prevent showing the scrolling
        z '.messages', {
          className: z.classKebab {isLoaded}
          key: 'conversation-messages'
          style:
            transform: "translateY(#{inputTranslateY}px)"
        },
          [
            # hidden by css, shown with js (non-vdom for perf)
            z '.loading-more', {
              key: 'conversation-messages-loading-spinner'
            },
              @$loadingMoreSpinner
            # hidden when inactive for perf
            if messageBatches and not isLoading
              _map messageBatches, (messageBatch) ->
                z '.message-batch', {
                  key: "message-batch-#{messageBatch?[0]?.id}"
                },
                  _map messageBatch, ({$el, isGrouped}, i) ->
                    [
                        if i and not isGrouped
                          z '.divider'
                        z $el, {isTextareaFocused}
                    ]

            else
              @$loadingSpinner
          ]

      if group and groupUser is false
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
            onclick: =>
              @state.set isJoinLoading: true

              @model.signInDialog.openIfGuest me
              .then =>
                (if localStorage?['isPushTokenStored']
                  Promise.resolve()
                else
                  @model.pushNotificationSheet.openAndWait()
                ).then =>
                  @model.portal.call 'push.subscribeToTopic', {
                    topic: "group-#{group.id}"
                  }
                  .catch -> null
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
      else
        z '.bottom',
          @$conversationInput
