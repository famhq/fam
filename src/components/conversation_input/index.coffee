z = require 'zorium'
_map = require 'lodash/map'
_pick = require 'lodash/pick'
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
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class ConversationInput
  constructor: (options) ->
    {@model, @router, @message, @onPost, @onResize, toggleIScroll,
      @inputTranslateY, allowedPanels, @isTextareaFocused, @overlay$,
      isPostLoading, gameKey, conversation} = options

    allowedPanels ?= RxObservable.of ['text', 'stickers', 'gifs', 'image']
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
        @message.next "![](#{config.USER_CDN_URL}/cm/#{key}.small.jpg" +
                          " =#{width}x#{height})"
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
          gameKey
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


    panelHeight = @currentPanel.switchMap (currentPanel) =>
      @panels[currentPanel].$el?.getHeightPx?()

    @inputTranslateY.next panelHeight.map (height) ->
      54 - height

    me = @model.user.getMe()

    @state = z.state
      currentPanel: @currentPanel
      me: me
      inputTranslateY: @inputTranslateY.switch()
      panelHeight: panelHeight
      panels: allowedPanels.map (allowedPanels) =>
        _pick @panels, allowedPanels
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
      post()
    else
      @model.signInDialog.openIfGuest me
      .then ->
        # SUPER HACK:
        # stream doesn't update while cache is being invalidated, for whatever
        # reason, so this waits until invalidation for login is ~done
        new Promise (resolve) ->
          setTimeout ->
            post().then resolve
          , 500

  render: =>
    {currentPanel, mePlayer, me, inputTranslateY,
      panels, panelHeight} = @state.getValue()

    isVerified = mePlayer?.isVerified or config.ENV is config.ENVS.DEV

    baseHeight = 54
    scale = (panelHeight / baseHeight) or 1

    z '.z-conversation-input', {
      className: z.classKebab {
        "is-#{currentPanel}-panel": true
      }
      style:
        height: "#{panelHeight + 32}px"
    },
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
                       then colors.$white
                       else colors.$white54
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
