z = require 'zorium'
_map = require 'lodash/map'
_filter = require 'lodash/filter'
_last = require 'lodash/last'
_isEmpty = require 'lodash/isEmpty'
_debounce = require 'lodash/debounce'
Environment = require 'clay-environment'
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject
RxReplaySubject = require('rxjs/ReplaySubject').ReplaySubject
RxObservable = require('rxjs/Observable').Observable
require 'rxjs/add/observable/of'
require 'rxjs/add/observable/combineLatest'
require 'rxjs/add/observable/merge'
require 'rxjs/add/observable/fromEvent'
require 'rxjs/add/operator/share'

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
    @messages = new RxBehaviorSubject null

    lastConversationId = null

    loadedMessages = conversationAndMe.switchMap (resp) =>
      [conversation, me] = resp

      if lastConversationId isnt conversation.id
        isLoading.next true

      lastConversationId = conversation.id

      (if conversation
        @model.chatMessage.getAllByConversationId(conversation.id)
      else
        RxObservable.of null)
      .map (messages) =>
        isLoading.next false
        isLoaded = not _isEmpty @state.getValue().messages
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
        messages
      .catch (err) ->
        console.log err
        RxObservable.of []
    .share()

    messages = RxObservable.merge @messages, loadedMessages

    @isScrolledBottomStreams = new RxReplaySubject 1
    @isScrolledBottomStreams.next RxObservable.of false
    @inputTranslateY = new RxReplaySubject 1

    @$loadingSpinner = new Spinner()
    @$refreshingSpinner = new Spinner()
    @$followButton = new PrimaryButton()
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
        if conversation.type is 'pm' or not conversation.groupId
          ['text', 'stickers', 'image', 'gifs']
        else
          ['text', 'stickers', 'gifs']
    }

    @debouncedOnResize = _debounce @onResize
    , RESIZE_THROTTLE_MS

    messagesAndMe = RxObservable.combineLatest(
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
      inputTranslateY: @inputTranslateY.switch()
      group: group
      isFollowLoading: false
      followingIds: @model.userFollower.getAllFollowingIds()
      isLoaded: false
      isScrolledBottom: @isScrolledBottomStreams.switch()

      messages: messagesAndMe.map ([messages, me]) =>
        if messages
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
            $body = @getCached$ message.clientId + ':text', FormattedText, {
              @model, @router, text: message.body
            }
            $el = @getCached$ id, ConversationMessage, {
              message, @model, @router, @overlay$, isMe,
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
    isScrolledBottom = RxObservable.fromEvent @$$messages, 'scroll'
    .map (e) ->
      e.target.scrollHeight - e.target.scrollTop - e.target.offsetHeight < 10
    @isScrolledBottomStreams.next isScrolledBottom

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
    @messages.next []

    @model.portal.call 'push.setContextId', {
      contextId: 'empty'
    }
    window?.removeEventListener 'resize', @debouncedOnResize

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
    {me, isLoading, message, isTextareaFocused, isLoaded, followingIds,
      messages, conversation, group, isScrolledBottom, inputTranslateY,
      isFollowLoading} = @state.getValue()

    z '.z-conversation',
      z '.g-grid',
        # hide messages until loaded to prevent showing the scrolling
        z '.messages', {
          className: z.classKebab {isLoaded}
          key: 'conversation-messages'
          style:
            transform: "translateY(#{inputTranslateY}px)"
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

      if group?.star and not
          @model.userFollower.isFollowing followingIds, group?.star?.user?.id
        z '.bottom.is-follow',
          z '.text',
            @model.l.get 'conversation.followMessage', {
              replacements:
                name: @model.user.getDisplayName group.star?.user
            }
          z @$followButton,
            text: if isFollowLoading \
                  then @model.l.get 'general.loading'
                  else @model.l.get 'profileInfo.followButtonText'
            onclick: =>
              @state.set isFollowLoading: true
              @model.userFollower.followByUserId group.star?.user?.id
              .then =>
                @state.set isFollowLoading: false
      else
        z '.bottom',
          @$conversationInput
