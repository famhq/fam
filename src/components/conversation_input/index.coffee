z = require 'zorium'
_map = require 'lodash/map'
Rx = require 'rx-lite'
supportsWebP = window? and require 'supports-webp'

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
    {@model, @message, @onPost, @onResize, toggleIScroll,
      @isTextareaFocused, @overlay$, isPostLoading} = options

    @imageData = new Rx.BehaviorSubject null
    @hasText = new Rx.BehaviorSubject false

    @$conversationImagePreview = new ConversationImagePreview {
      @imageData
      @overlay$
      @model
      onUpload: ({key, width, height}) =>
        @message.onNext "![](#{config.USER_CDN_URL}/cm/#{key}.small.png" +
                          " =#{width}x#{height})"
        @onPost()
    }

    @currentPanel = new Rx.BehaviorSubject 'text'

    @panels =
      text: {
        $icon: new Icon {hasRipple: true}
        icon: 'text'
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
        $icon: new Icon {hasRipple: true}
        icon: 'stickers'
        $el: new ConversationInputStickers {
          onPost: @post
          @message
        }
      }
      image: {
        $icon: new Icon {hasRipple: true}
        icon: 'image'
        onclick: -> null
        $uploadOverlay: new UploadOverlay {@model}
      }
      gifs: {
        $icon: new Icon {hasRipple: true}
        icon: 'gifs'
        $el: new ConversationInputGifs {
          onPost: @post
          @message
          @model
          @currentPanel
        }
      }

    @state = z.state
      currentPanel: @currentPanel
      me: @model.user.getMe()

  post: =>
    {me} = @state.getValue()

    @model.signInDialog.openIfGuest me
    .then =>
      # SUPER HACK:
      # stream doesn't update while cache is being invalidated, for whatever
      # reason, so this waits until invalidation for login is ~done
      setTimeout =>
        @onPost()
        @message.onNext ''
        @hasText.onNext false
      , 500

  render: =>
    {currentPanel} = @state.getValue()

    z '.z-conversation-input', {
      className: z.classKebab {"is-#{currentPanel}-panel": true}
    },
      z '.g-grid',
        z '.panel', {
          'ev-transitionend': =>
            @onResize?()
          style:
            height: "#{@panels[currentPanel].$el?.getHeightPx?()}px"
        },
          @panels[currentPanel].$el

        z '.bottom-icons',  {
          className: z.classKebab {isVisible: true}
        },
          [
            _map @panels, ({$icon, icon, onclick, $uploadOverlay}, panel) =>
              z '.icon',
                z $icon, {
                  onclick: onclick or =>
                    @currentPanel.onNext panel
                  icon: icon
                  color: if currentPanel is panel \
                         then colors.$white
                         else colors.$white54
                  isTouchTarget: true
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
                          @imageData.onNext {
                            file
                            dataUrl
                            width: img.width
                            height: img.height
                          }
                          @overlay$.onNext @$conversationImagePreview
                    }
            z '.powered-by-giphy'
          ]
