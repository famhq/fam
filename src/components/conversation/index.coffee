z = require 'zorium'
Rx = require 'rx-lite'
_map = require 'lodash/map'
_last = require 'lodash/last'
_isEmpty = require 'lodash/isEmpty'
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
DEFAULT_TEXTAREA_HEIGHT = 54

module.exports = class Conversation
  constructor: (options) ->
    {@model, @router, @error, @conversation, isActive,
      @selectedProfileDialogUser, @scrollYOnly} = options

    @$toAvatar = new Avatar()

    isLoading = new Rx.BehaviorSubject false
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

    @$sendIcon = new Icon()
    @$stickerIcon = new Icon()
    @$closeIcon = new Icon()
    @$loadingSpinner = new Spinner()
    @$refreshingSpinner = new Spinner()

    @state = z.state
      me: me
      isPostLoading: false
      isLoading: isLoading
      isActive: isActive
      isTextareaFocused: false
      error: null
      conversation: @conversation
      isStickerPanelVisible: false

      messages: messages.map (messages) ->
        if messages
          _map messages, (message) ->
            {
              messageInfo: message
              $avatar: new Avatar()
              $statusIcon: new Icon()
            }

  afterMount: (@$$el) =>
    clearInterval @refreshInterval
    @conversation.take(1).subscribe (conversation) =>
      @model.portal.call 'push.setContextId', {
        contextId: conversation.id
      }
    @scrollToBottom()

  beforeUnmount: =>
    clearInterval @refreshInterval
    # to update conversations page, etc...
    @model.exoid.invalidateAll()
    @messages.onNext []

    @model.portal.call 'push.setContextId', {
      contextId: null
    }

  resizeTextarea: (e) ->
    $$textarea = e.target
    $$textarea.style.height = "#{DEFAULT_TEXTAREA_HEIGHT}px"
    $$textarea.style.height = $$textarea.scrollHeight + 'px'
    $$textarea.scrollTop = $$textarea.scrollHeight

  scrollToBottom: ({isSmooth} = {}) =>
    $messages = @$$el?.querySelector('.messages')
    $messageArr = @$$el?.querySelectorAll('.message')
    if not @scrollYOnly and $messageArr and _last($messageArr)?.scrollIntoView
      $messageArr[$messageArr.length - 1].scrollIntoView {
        behavior: if isSmooth then 'smooth' else 'instant'
      }
    else if $messages
      $messages.scrollTop = $messages.scrollHeight - $messages.offsetHeight

  setMessage: (e) =>
    e or= window.event
    if e.keyCode is 13 and not e.shiftKey
      e.preventDefault()
      @postMessage()
    else
      @message.onNext e.target.value

  postMessage: (e) =>
    $$textarea = @$$el.querySelector('#textarea')
    $$textarea?.focus()
    $$textarea.style.height = 'auto'

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
      }, {user: me}
      .then =>
        # @model.user.emit('chatMessage').catch log.error
        @state.set isPostLoading: false
      .catch =>
        @state.set isPostLoading: false
      # hack: don't want to keep textarea value in state, too slow
      # to re-render on every letter typed
      @$$el.querySelector('.textarea').value = ''
      @message.onNext ''

  render: =>
    {me, isLoading, isPostLoading, message, isStickerPanelVisible,
      messages, conversation, isTextareaFocused} = @state.getValue()

    isLoaded = not _isEmpty messages

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

              onclick = =>
                unless isTextareaFocused
                  @selectedProfileDialogUser.onNext user

              z '.message', {
                # re-use elements in v-dom
                key: "message-#{messageInfo.id or messageInfo.clientId}"
                className: z.classKebab {isSticker, isMe: user.id is me?.id}
              },
                z '.avatar', {onclick},
                  z $avatar, {
                    user
                    size: if window?.matchMedia('(min-width: 840px)').matches \
                          then '56px'
                          else '40px'
                    bgColor: colors.$grey200
                  }
                z '.bubble', {onclick},
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
                    z '.time',
                      if time
                      then moment(time).fromNowModified()
                      else '...'
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
                      }, {user: me}
                      @state.set isStickerPanelVisible: false
                    style:
                      backgroundImage:
                        "url(#{config.CDN_URL}/groups/emotes/#{sticker}.png)"

        else
          z '.g-grid',
            z 'textarea.textarea',
              id: 'textarea'
              # for some reason necessary on iOS to get it to focus properly
              onclick: (e) ->
                setTimeout ->
                  e?.target?.focus()
                , 0
              placeholder: 'Type a message'
              onkeyup: @setMessage
              onkeydown: (e) ->
                if e.keyCode is 13 and not e.shiftKey
                  e.preventDefault
              oninput: @resizeTextarea
              onfocus: =>
                clearTimeout @blurTimeout
                @state.set isTextareaFocused: true
                setTimeout =>
                  @scrollToBottom {isSmooth: true}
                , RENDER_DELAY_MS
              onblur: =>
                @blurTimeout = setTimeout =>
                  @state.set isTextareaFocused: false
                , 350

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
