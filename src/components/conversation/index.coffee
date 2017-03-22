z = require 'zorium'
Rx = require 'rx-lite'
_map = require 'lodash/map'
_last = require 'lodash/last'
_isEmpty = require 'lodash/isEmpty'
_debounce = require 'lodash/debounce'

Spinner = require '../spinner'
Base = require '../base'
FormattedText = require '../formatted_text'
ConversationInput = require '../conversation_input'
ConversationMessage = require '../conversation_message'

if window?
  require './index.styl'

# we don't give immediate feedback for post (waits for cache invalidation and
# refetch), don't want users to post twice
MAX_POST_MESSAGE_LOAD_MS = 5000 # 5s
MAX_CHARACTERS = 500
MAX_LINES = 20
RESIZE_THROTTLE_MS = 150
FIVE_MINUTES_MS = 60 * 5 * 1000

module.exports = class Conversation extends Base
  constructor: (options) ->
    {@model, @router, @error, @conversation, isActive, @overlay$, toggleIScroll,
      selectedProfileDialogUser, @scrollYOnly, @isGroup} = options

    isLoading = new Rx.BehaviorSubject false
    @isPostLoading = new Rx.BehaviorSubject false
    isTextareaFocused = new Rx.BehaviorSubject false
    isActive ?= new Rx.BehaviorSubject false
    me = @model.user.getMe()
    @conversation ?= new Rx.BehaviorSubject null
    @error = new Rx.BehaviorSubject null

    conversationAndMe = Rx.Observable.combineLatest(
      @conversation
      me
      (vals...) -> vals
    )

    # not putting in state because re-render is too slow on type
    @message = new Rx.BehaviorSubject ''
    @messages = new Rx.BehaviorSubject null

    loadedMessages = conversationAndMe.flatMapLatest (resp) =>
      [conversation, me] = resp

      (if conversation
        @model.chatMessage.getAllByConversationId(conversation.id)
      else
        Rx.Observable.just null)
      .map (messages) =>
        isLoading.onNext false
        isLoaded = not _isEmpty @state.getValue().messages
        # HACK: give time for $formattedMessage to resolve
        {isScrolledBottom} = @state.getValue()
        if isScrolledBottom or not isLoaded
          setTimeout =>
            @scrollToBottom {
              isSmooth: isLoaded
            }
          , 100
          setTimeout =>
            @scrollToBottom {
              isSmooth: isLoaded
            }
          , 500
        messages
      .catch (err) ->
        console.log err
        Rx.Observable.just []
    .share()

    messages = Rx.Observable.merge @messages, loadedMessages

    @isScrolledBottomStreams = new Rx.ReplaySubject 1
    @isScrolledBottomStreams.onNext Rx.Observable.just false

    @$loadingSpinner = new Spinner()
    @$refreshingSpinner = new Spinner()
    @$conversationInput = new ConversationInput {
      @model
      @message
      isTextareaFocused
      toggleIScroll
      @overlay$
      onPost: @postMessage
      onResize: @onResize
    }

    @debouncedOnResize = _debounce @onResize
    , RESIZE_THROTTLE_MS

    messagesAndMe = Rx.Observable.combineLatest(
      messages
      @model.user.getMe()
      (vals...) -> vals
    )

    @state = z.state
      me: me
      isLoading: isLoading
      isActive: isActive
      isTextareaFocused: isTextareaFocused
      isPostLoading: @isPostLoading
      error: null
      conversation: @conversation
      isLoaded: false
      isScrolledBottom: @isScrolledBottomStreams.switch()

      messages: messagesAndMe.map ([messages, me]) =>
        if messages
          prevMessage = null
          _map messages, (message) =>
            isRecent = new Date(message.time) - new Date(prevMessage?.time) <
                        FIVE_MINUTES_MS
            isGrouped = message.userId is prevMessage?.userId and isRecent
            isMe = message.userId is me.id
            id = message.id or message.clientId
            # if we get this in conversationmessasge, there's a flicker for
            # state to get set
            $body = @getCached$ message.clientId + ':text', FormattedText, {
              @model, @router, text: message.body
            }
            $el = @getCached$ id, ConversationMessage, {
              message, @model, @router, @overlay$, isMe
              isGrouped, selectedProfileDialogUser, $body
            }
            prevMessage = message
            {$el, isGrouped}

  afterMount: (@$$el) =>
    @conversation.take(1).subscribe (conversation) =>
      @model.portal.call 'push.setContextId', {
        contextId: conversation?.id
      }
    @scrollToBottom()
    window?.addEventListener 'resize', @debouncedOnResize

    @$$messages = @$$el?.querySelector('.messages')
    # TODO: make sure this is being disposed of correctly
    isScrolledBottom = Rx.Observable.fromEvent @$$messages, 'scroll'
    .map (e) ->
      e.target.scrollHeight - e.target.scrollTop is e.target.offsetHeight
    @isScrolledBottomStreams.onNext isScrolledBottom

  beforeUnmount: =>
    # to update conversations page, etc...
    unless @isGroup
      # race condition without timeout.
      # new page tries to get new exoid stuff, but it gets cleared at same
      # exact time. caused an issue of leaving event page back to home,
      # and home had no responses / empty streams / unobserved streams
      # for group data
      setImmediate =>
        @model.exoid.invalidateAll()
    @messages.onNext []

    @model.portal.call 'push.setContextId', {
      contextId: null
    }
    window?.removeEventListener 'resize', @debouncedOnResize

  scrollToBottom: ({isSmooth} = {}) =>
    $messageArr = @$$el?.querySelectorAll('.message')
    $$lastMessage = _last $messageArr
    if not @scrollYOnly and $$lastMessage?.scrollIntoView
      try
        $$lastMessage.scrollIntoView {
          behavior: if isSmooth then 'smooth' else 'instant'
        }
    else if @$$messages
      @$$messages.scrollTop = @$$messages.scrollHeight -
                                @$$messages.offsetHeight



    {messages} = @state.getValue()
    @state.set isLoaded: not _isEmpty messages

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
    #   @error.onNext 'Message is too long'
    #   return

    if not isPostLoading and messageBody
      @isPostLoading.onNext true

      @model.chatMessage.create {
        body: messageBody
        conversationId: conversation?.id
        userId: me?.id
      }, {user: me, time: Date.now()}
      .then =>
        # @model.user.emit('chatMessage').catch log.error
        @isPostLoading.onNext false
      .catch =>
        @isPostLoading.onNext false

  render: =>
    {me, isLoading, message, isTextareaFocused, isLoaded
      messages, conversation, isScrolledBottom} = @state.getValue()

    z '.z-conversation',
      z '.g-grid',
        # hide messages until loaded to prevent showing the scrolling
        z '.messages', {
          className: z.classKebab {isLoaded}
          key: 'conversation-messages'
        },
          # hidden when inactive for perf
          if messages and not isLoading
            _map messages, ({$el, isGrouped}, i) ->
              [
                if i and not isGrouped
                  z '.divider'
                z $el, {isTextareaFocused}
              ]

          else
            @$loadingSpinner

      z '.bottom',
        @$conversationInput
