z = require 'zorium'
_map = require 'lodash/map'
_upperFirst = require 'lodash/upperFirst'
supportsWebP = window? and require 'supports-webp'
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject
RxReplaySubject = require('rxjs/ReplaySubject').ReplaySubject
require 'rxjs/add/operator/switchMap'

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
    {@model, @message, @onPost, @onResize, toggleIScroll, @inputTranslateY,
      @isTextareaFocused, @overlay$, isPostLoading} = options

    @imageData = new RxBehaviorSubject null
    @hasText = new RxBehaviorSubject false
    @isTextareaFocused ?= new RxBehaviorSubject false

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
        requireVerified: true
        $el: new ConversationInputStickers {
          onPost: @post
          @message
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

    @inputTranslateY.next @currentPanel.map (currentPanel) =>
      54 - @panels[currentPanel].$el?.getHeightPx?()

    me = @model.user.getMe()

    @state = z.state
      currentPanel: @currentPanel
      me: me
      inputTranslateY: @inputTranslateY.switch()
      mePlayer: me.switchMap ({id}) =>
        @model.player.getByUserIdAndGameId id, config.CLASH_ROYALE_ID

  post: =>
    {me} = @state.getValue()

    post = =>
      @onPost()
      @message.next ''
      @hasText.next false

    if me?.isMember
      post()
    else
      @model.signInDialog.openIfGuest me
      .then ->
        # SUPER HACK:
        # stream doesn't update while cache is being invalidated, for whatever
        # reason, so this waits until invalidation for login is ~done
        setTimeout post, 500

  render: =>
    {currentPanel, mePlayer, me, inputTranslateY} = @state.getValue()

    isVerified = mePlayer?.isVerified or config.ENV is config.ENVS.DEV

    baseHeight = 54
    scale = (@panels[currentPanel].$el?.getHeightPx?() / baseHeight) or 1

    z '.z-conversation-input', {
      className: z.classKebab {"is-#{currentPanel}-panel": true}
      style:
        height: "#{@panels[currentPanel].$el?.getHeightPx?() + 32}px"
    },
      z '.g-grid',
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
            _map @panels, (options, panel) =>
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
