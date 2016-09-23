z = require 'zorium'
Rx = require 'rx-lite'
colors = require '../../colors'
_map = require 'lodash/collection/map'
_mapValues = require 'lodash/object/mapValues'
_isEmpty = require 'lodash/lang/isEmpty'
log = require 'loga'
Environment = require 'clay-environment'
moment = require 'moment'

config = require '../../config'
Avatar = require '../avatar'
Icon = require '../icon'
Spinner = require '../spinner'
# ProfileDialog = require '../profile_dialog'

if window?
  require './index.styl'

# we don't give immediate feedback for post (waits for cache invalidation and
# refetch), don't want users to post twice
MAX_POST_MESSAGE_LOAD_MS = 5000 # 5s
REFRESH_INTERVAL_MS = 7000 # 7s
PAUSE_WHILE_TYPING_DELAY_MS = 1000 # 1s
MAX_CHARACTERS = 500
MAX_LINES = 20
RENDER_DELAY_MS = 100

module.exports = class Conversation
  constructor: ({@model, @router, @error, isRefreshing, toUser}) ->
    @$toAvatar = new Avatar()

    # SUPER HACK
    isLoading = new Rx.BehaviorSubject false

    @autoUpdate = new Rx.BehaviorSubject 0
    @isRefreshPaused # we don't refresh when the user is typing
    @isRefreshPausedTimeout = null
    me = @model.user.getMe()

    @toUserAndAutoUpdateAndMe = Rx.Observable.combineLatest(
      toUser
      # TODO: maybe replace with subscribe / dispose
      @autoUpdate
      me
      (vals...) -> vals
    )

    # not putting in state because re-render is too slow on type
    @message = new Rx.BehaviorSubject ''
    @messages = @toUserAndAutoUpdateAndMe.flatMapLatest (resp) =>
      [toUser, autoUpdate, me] = resp

      isRefreshing.onNext true

      (if filter?.privateUserId
        @model.chatMessage.getPrivateByUserId(
          filter.privateUserId, {ignoreCache: autoUpdate}
        )
      else if filter?.channel
        @model.chatMessage.getByChannel {
          channel: filter.channel
        }, {
          ignoreCache: autoUpdate
        }
      else
        Rx.Observable.just null)
      # SUPER HACK to get loading spinner to work while changing filter
      .map (response) =>
        isLoading.onNext false
        isRefreshing.onNext false
        setTimeout =>
          @scrollToBottom()
        , RENDER_DELAY_MS

        response?.reverse?()
      .catch (err) ->
        console.log err
        Rx.Observable.just []
    .share()

    @$sendIcon = new Icon()
    @$loadingSpinner = new Spinner()
    @$refreshingSpinner = new Spinner()


    @state = z.state
      me: me
      isPostLoading: false
      isLoading: isLoading
      isRefreshing: isRefreshing
      error: null
      toUser: toUser

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
    @autoUpdate.onNext Date.now()

    @refreshInterval = setInterval =>
      {filter, isFilterMenuVisible, isRefreshing} = @state.getValue()
      $messages = @$$el?.querySelector('.messages')
      if $messages
        pos = Math.ceil $messages.scrollTop
        bottom = $messages.scrollHeight - $messages.offsetHeight
        isBottomOfPage = pos >= bottom

        if isBottomOfPage and not isFilterMenuVisible and
            not isRefreshing and not @isRefreshPaused
          @autoUpdate.onNext Date.now()
    , REFRESH_INTERVAL_MS

  beforeUnmount: =>
    clearInterval @refreshInterval

  scrollToBottom: =>
    $messages = @$$el?.querySelector('.messages')
    if $messages
      $messages.scrollTop = $messages.scrollHeight - $messages.offsetHeight

  setMessage: (e) =>
    @message.onNext e.target.value
    @isRefreshPaused = true
    clearTimeout @isRefreshPausedTimeout
    @isRefreshPausedTimeout = setTimeout =>
      @isRefreshPaused = false
    , PAUSE_WHILE_TYPING_DELAY_MS

  render: =>
    {me, isLoading, isPostLoading, message, messages, toUser,
      selectedProfileDialogUser, filter} = @state.getValue()
    z '.z-conversation',
      z '.g-grid',
        z '.messages',
          # hidden when inactive for perf
          if messages and not isLoading
            _map messages, ({messageInfo, $avatar, $statusIcon}) =>
              {user, body, time} = messageInfo
              textLines = body.split('\n') or []

              z '.message', {
                key: "message-#{messageInfo.id}" # re-use elements in v-dom
                # onclick: =>
                #   @selectedProfileDialogUser.onNext user
              },
                z '.avatar',
                  z $avatar, {
                    user
                    size: if window?.matchMedia('(min-width: 840px)').matches \
                          then '56px'
                          else '40px'
                    bgColor: colors.$grey200
                  }
                z '.content',
                  z '.info', {
                    style:
                      color: colors.$tertiary900
                  },
                    if user?.flags?.isModerator or user?.flags?.isDev
                      z '.icon',
                        z $statusIcon,
                          icon: if user?.flags?.isDev then 'dev' else 'mod'
                          color: colors.$tertiary900
                          isTouchTarget: false
                          size: '22px'
                    z '.name', @model.user.getDisplayName user

                  z '.body', {
                    style:
                      color: colors.$grey600
                  },
                    _map textLines, (text) ->
                      z 'div', text
                  z '.bottom',
                    z '.time', moment(time).fromNow()
          else
            @$loadingSpinner

      z '.textarea-container',
        z '.g-grid',
          z 'textarea.textarea',
            # for some reason necessary on iOS to get it to focus properly
            onclick: (e) ->
              setTimeout ->
                e?.target?.focus()
              , 0
            placeholder: 'Type a message'
            onkeyup: @setMessage
            onchange: @setMessage
            onblur: =>
              @isRefreshPaused = false

          z '.icons',
            z '.send-icon', {
              onclick: =>
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

                  channel = filter?.channel

                  @model.chatMessage.create {
                    body: messageBody
                    toId: filter?.privateUserId
                    channel: channel
                  }
                  .then =>
                    # @model.user.emit('chatMessage').catch log.error
                    @autoUpdate.onNext Date.now()
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
            },
              z @$sendIcon,
                icon: 'send'
                color: if isPostLoading \
                       then colors.$grey200
                       else colors.$white30

      # if selectedProfileDialogUser
      #   z @$profileDialog
