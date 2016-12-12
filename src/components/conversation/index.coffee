z = require 'zorium'
Rx = require 'rx-lite'
_map = require 'lodash/map'
Environment = require 'clay-environment'
moment = require 'moment'

config = require '../../config'
colors = require '../../colors'
Avatar = require '../avatar'
Icon = require '../icon'
Spinner = require '../spinner'
FormatService = require '../../services/format'

if window?
  require './index.styl'

# we don't give immediate feedback for post (waits for cache invalidation and
# refetch), don't want users to post twice
MAX_POST_MESSAGE_LOAD_MS = 5000 # 5s
MAX_CHARACTERS = 500
MAX_LINES = 20
RENDER_DELAY_MS = 100

module.exports = class Conversation
  constructor: (options) ->
    {@model, @router, @error, isRefreshing, conversation,
      @selectedProfileDialogUser} = options

    @$toAvatar = new Avatar()

    # SUPER HACK
    isLoading = new Rx.BehaviorSubject false

    me = @model.user.getMe()
    conversation ?= new Rx.BehaviorSubject null
    isRefreshing ?= new Rx.BehaviorSubject null

    @conversationAndMe = Rx.Observable.combineLatest(
      conversation
      me
      (vals...) -> vals
    )

    # not putting in state because re-render is too slow on type
    @message = new Rx.BehaviorSubject ''
    @messages = @conversationAndMe.flatMapLatest (resp) =>
      [conversation, me] = resp

      isRefreshing.onNext true

      (if conversation
        @model.chatMessage.getAllByConversationId(
          conversation.id
        )
      else
        Rx.Observable.just null)
      .map (response) =>
        isLoading.onNext false
        isRefreshing.onNext false
        setTimeout =>
          @scrollToBottom()
          @state.set isLoaded: true
        , RENDER_DELAY_MS
        response
      .catch (err) ->
        console.log err
        Rx.Observable.just []
    .share()

    @$sendIcon = new Icon()
    @$stickerIcon = new Icon()
    @$closeIcon = new Icon()
    @$loadingSpinner = new Spinner()
    @$refreshingSpinner = new Spinner()


    @state = z.state
      me: me
      isPostLoading: false
      isLoading: isLoading
      isRefreshing: isRefreshing
      isTextareaFocused: false
      error: null
      conversation: conversation
      isLoaded: false
      isStickerPanelVisible: false

      messages: @messages.map (messages) ->
        if messages
          _map messages, (message) ->
            {
              messageInfo: message
              $avatar: new Avatar()
              $statusIcon: new Icon()
            }

  afterMount: (@$$el) =>
    clearInterval @refreshInterval
    @scrollToBottom()

  beforeUnmount: =>
    clearInterval @refreshInterval

  scrollToBottom: =>
    $messages = @$$el?.querySelector('.messages')
    if $messages and $messages[$messages.length - 1]?.scrollIntoView
      $messages[$messages.length - 1].scrollIntoView()
    else if $messages
      $messages.scrollTop = $messages.scrollHeight - $messages.offsetHeight

  setMessage: (e) =>
    e or= window.event
    if e.keyCode is 13
      e.preventDefault()
      @postMessage()
    else
      @message.onNext e.target.value

  postMessage: =>
    {me, conversation, isPostLoading} = @state.getValue()

    messageBody = @message.getValue()
    lineBreaks =  messageBody.split(/\r\n|\r|\n/).length
    if messageBody.length > MAX_CHARACTERS or
        lineBreaks > MAX_LINES
      @error.onNext 'Message is too long'
      return

    msPlayed = Date.now() - Date.parse(me?.joinTime)
    isNative = Environment.isGameApp(config.GAME_KEY)

    if msPlayed < config.NEW_USER_CHAT_TIME_MS and not isNative
      @error.onNext 'You don\'t have permission to post yet'
      return

    if not isPostLoading and messageBody
      @state.set isPostLoading: true

      @model.chatMessage.create {
        body: messageBody
        conversationId: conversation?.id
      }
      .then =>
        # @model.user.emit('chatMessage').catch log.error
        doneTimeout = setTimeout =>
          @state.set isPostLoading: false
        , MAX_POST_MESSAGE_LOAD_MS
        messageSub = @messages.take(1)
        messageSub.subscribe =>
          @state.set isPostLoading: false
          clearTimeout doneTimeout
        messageSub.catch =>
          @state.set isPostLoading: false
          clearTimeout doneTimeout
      .catch =>
        @state.set isPostLoading: false
      # hack: don't want to keep textarea value in state, too slow
      # to re-render on every letter typed
      @$$el.querySelector('.textarea').value = ''
      @message.onNext ''

  render: =>
    {me, isLoading, isPostLoading, message, isStickerPanelVisible,
      messages, conversation, isLoaded, isTextareaFocused} = @state.getValue()

    z '.z-conversation', {
      className: z.classKebab {isTextareaFocused}
    },
      z '.g-grid',
        # hide messages until loaded to prevent showing the scrolling
        z '.messages', {className: z.classKebab {isLoaded}},
          # hidden when inactive for perf
          if messages and not isLoading
            _map messages, ({messageInfo, $avatar, $statusIcon}) =>
              {user, body, time} = messageInfo

              isSticker = body.match /^:[a-z_]+:$/

              z '.message', {
                key: "message-#{messageInfo.id}" # re-use elements in v-dom
                className: z.classKebab {isSticker, isMe: user.id is me?.id}
                onclick: =>
                  @selectedProfileDialogUser.onNext user
              },
                z '.avatar',
                  z $avatar, {
                    user
                    size: if window?.matchMedia('(min-width: 840px)').matches \
                          then '56px'
                          else '40px'
                    bgColor: colors.$grey200
                  }
                z '.bubble',
                  z '.info',
                    if user?.flags?.isModerator or user?.flags?.isDev
                      z '.icon',
                        z $statusIcon,
                          icon: if user?.flags?.isDev then 'dev' else 'mod'
                          color: colors.$tertiary900
                          isTouchTarget: false
                          size: '22px'

                  z '.body',
                      FormatService.message body
                  z '.bottom',
                    z '.name', @model.user.getDisplayName user
                    z '.middot',
                      innerHTML: '&middot;'
                    z '.time', moment(time).fromNowModified()
          else
            @$loadingSpinner

      z '.bottom',
        if isStickerPanelVisible
          z '.g-grid',
            z '.sticker-panel',
              z '.close-icon',
                z @$closeIcon,
                  icon: 'close'
                  color: colors.$white
                  isAlignedTop: true
                  isAlignedRight: true
                  onclick: =>
                    @state.set isStickerPanelVisible: false
              z '.title', 'Share sticker'
              z '.stickers',
                _map config.STICKERS, (sticker) =>
                  z '.sticker',
                    onclick: =>
                      @model.chatMessage.create {
                        body: ":#{sticker}:"
                        conversationId: conversation?.id
                      }
                      @state.set isStickerPanelVisible: false
                    style:
                      backgroundImage:
                        "url(#{config.CDN_URL}/groups/emotes/#{sticker}.png)"

        else
          z '.g-grid',
            z 'textarea.textarea',
              # for some reason necessary on iOS to get it to focus properly
              onclick: (e) ->
                setTimeout ->
                  e?.target?.focus()
                , 0
              placeholder: 'Type a message'
              onkeyup: @setMessage
              onkeydown: (e) ->
                e or= window.event
                if e.keyCode is 13
                  e.preventDefault()
              onchange: @setMessage
              onfocus: =>
                @state.set isTextareaFocused: true
                setTimeout =>
                  @scrollToBottom()
                , RENDER_DELAY_MS
              onblur: =>
                @state.set isTextareaFocused: false

            z '.icons',
              z '.sticker-icon',
                z @$stickerIcon, {
                  onclick: =>
                    @state.set isStickerPanelVisible: true
                  icon: 'stickers'
                  color: colors.$white
                }
              z '.send-icon', {
                onclick: @postMessage
              },
                z @$sendIcon,
                  icon: 'send'
                  color: if isPostLoading \
                         then colors.$grey200
                         else colors.$white
