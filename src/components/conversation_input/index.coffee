z = require 'zorium'
_map = require 'lodash/map'
_pick = require 'lodash/pick'
_maxBy = require 'lodash/maxBy'
_upperFirst = require 'lodash/upperFirst'
supportsWebP = window? and require 'supports-webp'
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject
RxReplaySubject = require('rxjs/ReplaySubject').ReplaySubject
RxObservable = require('rxjs/Observable').Observable
require 'rxjs/add/operator/switchMap'
require 'rxjs/add/observable/of'

Icon = require '../icon'
UploadOverlay = require '../upload_overlay'
ConversationImagePreview = require '../conversation_image_preview'
ConversationInputTextarea = require '../conversation_input_textarea'
ConversationInputStickers = require '../conversation_input_stickers'
ConversationInputGifs = require '../conversation_input_gifs'
ConversationInputAddons = require '../conversation_input_addons'
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class ConversationInput
  constructor: (options) ->
    {@model, @router, @message, @onPost, @onResize, toggleIScroll, meGroupUser,
      @inputTranslateY, allowedPanels, @isTextareaFocused, @overlay$,
      isPostLoading, conversation} = options

    allowedPanels ?= RxObservable.of [
      'text', 'stickers', 'gifs', 'image', 'addons'
    ]
    @imageData = new RxBehaviorSubject null
    @hasText = new RxBehaviorSubject false
    @isTextareaFocused ?= new RxBehaviorSubject false
    selectionStart = new RxBehaviorSubject 0
    selectionEnd = new RxBehaviorSubject 0

    @$conversationImagePreview = new ConversationImagePreview {
      @imageData
      @overlay$
      @model
      onUpload: ({key, width, height}) =>
        @message.next "![](<#{config.USER_CDN_URL}/cm/#{key}.small.jpg" +
                          " =#{width}x#{height}>)"
        @onPost()
    }

    @currentPanel = new RxBehaviorSubject 'text'
    @inputTranslateY ?= new RxReplaySubject 1

    @panels =
      text: {
        $icon: new Icon()
        icon: 'text'
        name: 'text'
        $el: new ConversationInputTextarea {
          onPost: @post
          @onResize
          @message
          selectionStart
          selectionEnd
          @isTextareaFocused
          toggleIScroll
          isPostLoading
          @hasText
          @model
        }
      }
      stickers: {
        $icon: new Icon()
        icon: 'stickers'
        name: 'stickers'
        # requireVerified: true
        $el: new ConversationInputStickers {
          @model
          @router
          onPost: @post
          @message
          selectionStart
          selectionEnd
          @currentPanel
          conversation
        }
      }
      image: {
        $icon: new Icon()
        icon: 'image'
        name: 'images'
        requireVerified: true
        onclick: -> null
        $uploadOverlay: new UploadOverlay {@model}
      }
      gifs: {
        $icon: new Icon()
        icon: 'gifs'
        name: 'gifs'
        requireVerified: true
        $el: new ConversationInputGifs {
          onPost: @post
          @message
          @model
          @currentPanel
        }
      }
      addons: {
        $icon: new Icon()
        icon: 'ellipsis'
        name: 'addons'
        $el: new ConversationInputAddons {
          onPost: @post
          @message
          @model
          @router
          @currentPanel
        }
      }

    @defaultPanelHeight = @panels.text.$el.getHeightPx()

    panelHeight = @currentPanel.switchMap (currentPanel) =>
      @panels[currentPanel].$el?.getHeightPx?()

    @inputTranslateY.next panelHeight.map (height) ->
      54 - height

    me = @model.user.getMe()

    @lastClientTime = new RxBehaviorSubject null
    update = new RxBehaviorSubject null
    cooldownSecondsLeft = conversation?.switchMap (conversation) =>
      isSlowMode = conversation?.data?.isSlowMode
      if isSlowMode
        lastServerTime = @model.chatMessage.getLastTimeByMeAndConversationId(
          conversation.id
        )
        lastServerTimeAndLastClientTimeAndUpdate = RxObservable.combineLatest(
          lastServerTime, @lastClientTime, update, (vals...) -> vals
        )
        lastServerTimeAndLastClientTimeAndUpdate
        .map ([lastServerTime, lastClientTime]) ->
          if lastServerTime
            lastServerTime = new Date(lastServerTime)
          _maxBy [lastServerTime, lastClientTime], (time) ->
            time?.getTime?() or 0
        .map (lastMeMessageTime) ->
          isSlowMode = conversation?.data?.isSlowMode
          slowModeCooldownSeconds = conversation?.data?.slowModeCooldown
          msSinceLastMessage = Date.now() -
                                (new Date(lastMeMessageTime)).getTime()
          cooldownSecondsLeft = slowModeCooldownSeconds -
                                  Math.floor(msSinceLastMessage / 1000)
          if cooldownSecondsLeft > 0 # re-render every second til 0
            setTimeout (-> update.next Date.now()), 1000
          cooldownSecondsLeft

      else
        RxObservable.of 0
    unless cooldownSecondsLeft # for forum
      cooldownSecondsLeft = 0

    @state = z.state
      currentPanel: @currentPanel
      me: me
      inputTranslateY: @inputTranslateY.switch()
      panelHeight: panelHeight
      panels: allowedPanels.map (allowedPanels) =>
        _pick @panels, allowedPanels
      meGroupUser: meGroupUser
      conversation: conversation
      cooldownSecondsLeft: cooldownSecondsLeft
      mePlayer: me.switchMap ({id}) =>
        @model.player.getByUserIdAndGameId id, config.CLASH_ROYALE_ID

  post: =>
    {me} = @state.getValue()

    post = =>
      promise = @onPost()
      @message.next ''
      @hasText.next false
      promise

    if me?.isMember
      @lastClientTime.next new Date()
      post()
    else
      @model.signInDialog.openIfGuest me
      .then =>
        @lastClientTime.next new Date()
        # SUPER HACK:
        # stream doesn't update while cache is being invalidated, for whatever
        # reason, so this waits until invalidation for login is ~done
        new Promise (resolve) ->
          setTimeout ->
            post().then resolve
          , 500

  render: =>
    {currentPanel, mePlayer, me, inputTranslateY, meGroupUser, conversation,
      panels, panelHeight, cooldownSecondsLeft} = @state.getValue()

    isVerified = mePlayer?.isVerified or config.ENV is config.ENVS.DEV

    baseHeight = 54
    panelHeight or= @defaultPanelHeight
    scale = (panelHeight / baseHeight) or 1

    bypassSlowMode = @model.groupUser.hasPermission {
      meGroupUser, permissions: ['bypassSlowMode'], channelId: conversation?.id
    }
    if cooldownSecondsLeft > 0 and not bypassSlowMode
      lockedBySlow = true
    else
      lockedBySlow = false

    z '.z-conversation-input', {
      className: z.classKebab {
        "is-#{currentPanel}-panel": true
      }
      style:
        height: "#{panelHeight + 32}px"
    },
      if lockedBySlow
        z '.locked',
          @model.l.get 'conversation.slowMode', {
            replacements:
              seconds: cooldownSecondsLeft
          }
      z '.panel', {
        'ev-transitionend': =>
          @onResize?()
        style:
          transform: "translateY(#{inputTranslateY}px)"
      },
        if @panels[currentPanel].requireVerified and not isVerified
          z '.require-verified',
              z '.title',
                @model.l.get(
                  "conversationInput.unlock#{_upperFirst currentPanel}"
                )
              z '.description',
                @model.l.get 'conversationInput.unlockDescription'
        @panels[currentPanel].$el

      z '.bottom-icons',  {
        className: z.classKebab {isVisible: true}
      },
        [
          _map panels, (options, panel) =>
            {$icon, icon, onclick, $uploadOverlay, requireVerified} = options
            if requireVerified and $uploadOverlay and not isVerified
              return
            z '.icon',
              z $icon, {
                onclick: onclick or =>
                  @currentPanel.next panel
                icon: icon
                color: if currentPanel is panel \
                       then colors.$tertiary900Text
                       else colors.$tertiary900Text54
                isTouchTarget: true
                hasRipple: true
                touchWidth: '36px'
                touchHeight: '36px'
              }
              if $uploadOverlay
                z '.upload-overlay',
                  z $uploadOverlay, {
                    onSelect: ({file, dataUrl}) =>
                      img = new Image()
                      img.src = dataUrl
                      img.onload = =>
                        @imageData.next {
                          file
                          dataUrl
                          width: img.width
                          height: img.height
                        }
                        @overlay$.next @$conversationImagePreview
                  }
          z '.powered-by-giphy'
        ]
