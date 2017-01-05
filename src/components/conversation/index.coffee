z = require 'zorium'
Rx = require 'rx-lite'
_map = require 'lodash/map'
_last = require 'lodash/last'
_isEmpty = require 'lodash/isEmpty'
_truncate = require 'lodash/truncate'
_filter = require 'lodash/filter'
Environment = require 'clay-environment'
moment = require 'moment'

config = require '../../config'
colors = require '../../colors'
Avatar = require '../avatar'
Icon = require '../icon'
Spinner = require '../spinner'
ConversationTextarea = require '../conversation_textarea'
ConversationImageView = require '../conversation_image_view'

if window?
  require './index.styl'

# we don't give immediate feedback for post (waits for cache invalidation and
# refetch), don't want users to post twice
MAX_POST_MESSAGE_LOAD_MS = 5000 # 5s
MAX_CHARACTERS = 500
MAX_LINES = 20
RENDER_DELAY_MS = 200
TITLE_LENGTH = 30
DESCRIPTION_LENGTH = 100
STICKER_REGEX_STR = '(:[a-z_]+:)'
STICKER_REGEX = new RegExp STICKER_REGEX_STR, 'g'
URL_REGEX_STR = '(\\bhttps?://[-A-Z0-9+&@#/%?=~_|!:,.;]*[A-Z0-9+&@#/%=~_|])'
URL_REGEX = new RegExp URL_REGEX_STR, 'gi'
IMAGE_REGEX_STR = '(\\!\\[(.*?)\\]\\(local://(.*?_([0-9.]+))\\))'
IMAGE_REGEX_BASE_STR = '(\\!\\[(?:.*?)\\]\\(local://(?:.*?_(?:[0-9.]+))\\))'
ALL_REGEX_STR = "#{STICKER_REGEX_STR}|#{URL_REGEX_STR}|#{IMAGE_REGEX_BASE_STR}"
ALL_REGEX = new RegExp ALL_REGEX_STR, 'gi'

module.exports = class Conversation
  constructor: (options) ->
    {@model, @router, @error, @conversation, isActive, @overlay$,
      @selectedProfileDialogUser, @scrollYOnly, @isGroup} = options

    @$toAvatar = new Avatar()

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

    @imageData = new Rx.BehaviorSubject null
    @$conversationImageView = new ConversationImageView {
      @imageData
      @overlay$
      @router
    }

    @$loadingSpinner = new Spinner()
    @$refreshingSpinner = new Spinner()
    @$conversationTextarea = new ConversationTextarea {
      @model
      @message
      isTextareaFocused
      @overlay$
      onPost: @postMessage
      onFocus: =>
        setTimeout =>
          @scrollToBottom {isSmooth: true}
        , RENDER_DELAY_MS
    }

    @state = z.state
      me: me
      isLoading: isLoading
      isActive: isActive
      isTextareaFocused: isTextareaFocused
      error: null
      conversation: @conversation

      messages: messages.map (messages) ->
        if messages
          _map messages, (message) ->
            {
              messageInfo: message
              $avatar: new Avatar()
              $statusIcon: new Icon()
            }

  afterMount: (@$$el) =>
    @conversation.take(1).subscribe (conversation) =>
      @model.portal.call 'push.setContextId', {
        contextId: conversation?.id
      }
    @scrollToBottom()

  beforeUnmount: =>
    # to update conversations page, etc...
    unless @isGroup
      @model.exoid.invalidateAll()
    @messages.onNext []

    @model.portal.call 'push.setContextId', {
      contextId: null
    }

  scrollToBottom: ({isSmooth} = {}) =>
    $messages = @$$el?.querySelector('.messages')
    $messageArr = @$$el?.querySelectorAll('.message')
    $$lastMessage = _last $messageArr
    if not @scrollYOnly and $$lastMessage?.scrollIntoView
      try
        $$lastMessage.scrollIntoView {
          behavior: if isSmooth then 'smooth' else 'instant'
        }
    else if $messages
      $messages.scrollTop = $messages.scrollHeight - $messages.offsetHeight

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
      }, {user: me}
      .then =>
        # @model.user.emit('chatMessage').catch log.error
        @state.set isPostLoading: false
      .catch =>
        @state.set isPostLoading: false

  formatMessage: (message) =>
    textLines = message.split('\n') or []
    _map textLines, (text) =>
      parts = _filter text.split ALL_REGEX
      z 'div',
        _map parts, (part) =>
          # need to create new regex each time (since exec grabs nth match)
          if matches = new RegExp(IMAGE_REGEX_STR, 'gi').exec(part)
            imageUrl = "#{config.USER_CDN_URL}/cm/#{matches[3]}.small.png"
            largeImageUrl = "#{config.USER_CDN_URL}/cm/#{matches[3]}.large.png"
            imageAspectRatio = matches[4]
            z 'img', {
              src: imageUrl
              width: 100
              height: 100 / imageAspectRatio
              onclick: (e) =>
                e?.stopPropagation()
                e?.preventDefault()
                @overlay$.onNext @$conversationImageView
                @imageData.onNext {
                  url: largeImageUrl
                  aspectRatio: imageAspectRatio
                }
            }
          else if part.match STICKER_REGEX
            sticker = part.replace /:/g, ''
            z '.sticker',
              style:
                backgroundImage:
                  "url(#{config.CDN_URL}/groups/emotes/#{sticker}.png)"

          else if part.match URL_REGEX
            z 'a.link', {
              href: part
              onclick: (e) =>
                e?.stopPropagation()
                e?.preventDefault()
                @model.portal.call 'browser.openWindow', {
                  url: part
                  target: '_system'
                }
            }, part
          else
            part

  render: =>
    {me, isLoading, message, isTextareaFocused
      messages, conversation} = @state.getValue()

    isLoaded = not _isEmpty messages

    z '.z-conversation',
      z '.g-grid',
        # hide messages until loaded to prevent showing the scrolling
        z '.messages', {className: z.classKebab {isLoaded}},
          # hidden when inactive for perf
          if messages and not isLoading
            _map messages, ({messageInfo, $avatar, $statusIcon}) =>
              {user, body, time, card} = messageInfo

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
                      @formatMessage body
                  z '.bottom',
                    z '.name', @model.user.getDisplayName user
                    z '.middot',
                      innerHTML: '&middot;'
                    z '.time',
                      if time
                      then moment(time).fromNowModified()
                      else '...'
                  if card
                    z '.card', {
                      onclick: (e) =>
                        e?.stopPropagation()
                        @model.portal.call 'browser.openWindow', {
                          url: card.url
                          target: '_system'
                        }
                    },
                      z '.title', _truncate card.title, {length: TITLE_LENGTH}
                      z '.description', _truncate card.description, {
                        length: DESCRIPTION_LENGTH
                      }
          else
            @$loadingSpinner

      z '.bottom',
        @$conversationTextarea
