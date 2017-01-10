z = require 'zorium'
Rx = require 'rx-lite'
_map = require 'lodash/map'
_last = require 'lodash/last'
_isEmpty = require 'lodash/isEmpty'
_debounce = require 'lodash/debounce'

Spinner = require '../spinner'
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

module.exports = class Conversation
  constructor: (options) ->
    {@model, @router, @error, @conversation, isActive, @overlay$,
      @selectedProfileDialogUser, @scrollYOnly, @isGroup} = options

    isLoading = new Rx.BehaviorSubject false
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
        setTimeout =>
          @scrollToBottom {
            isSmooth: isLoaded
          }
        , 0
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
      @overlay$
      onPost: @postMessage
      onResize: @onResize
    }

    @debouncedOnResize = _debounce @onResize
    , RESIZE_THROTTLE_MS

    @state = z.state
      me: me
      isLoading: isLoading
      isActive: isActive
      isTextareaFocused: isTextareaFocused
      error: null
      conversation: @conversation
      isScrolledBottom: @isScrolledBottomStreams.switch()

      messages: messages.map (messages) =>
        if messages
          _map messages, (message) =>
            new ConversationMessage {message, @model, @overlay$}

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

  onResize: =>
    {isScrolledBottom} = @state.getValue()
    if isScrolledBottom
      setTimeout =>
        @scrollToBottom {isSmooth: true}
      , 0

  postMessage: =>
    {me, conversation, isPostLoading} = @state.getValue()

    messageBody = @message.getValue()
    lineBreaks =  messageBody.split(/\r\n|\r|\n/).length
    if messageBody.length > MAX_CHARACTERS or
        lineBreaks > MAX_LINES
      @error.onNext 'Message is too long'
      return

    if not isPostLoading and messageBody
      @state.set isPostLoading: true

      @model.chatMessage.create {
        body: messageBody
        conversationId: conversation?.id
      }, {user: me}
      .then =>
        # @model.user.emit('chatMessage').catch log.error
        @state.set isPostLoading: false
      .catch =>
        @state.set isPostLoading: false

  render: =>
    {me, isLoading, message, isTextareaFocused
      messages, conversation, isScrolledBottom} = @state.getValue()
    isLoaded = not _isEmpty messages

    z '.z-conversation',
      z '.g-grid',
        # hide messages until loaded to prevent showing the scrolling
        z '.messages', {
          className: z.classKebab {isLoaded}
          key: 'conversation-messages'
        },
          # hidden when inactive for perf
          if messages and not isLoading
            _map messages, ($message) ->
              z $message, {isTextareaFocused}

          else
            @$loadingSpinner

      z '.bottom',
        @$conversationInput
