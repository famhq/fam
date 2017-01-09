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
    {@model, @message, @onPost, @onFocus,
      @isTextareaFocused, @overlay$} = options

    @imageData = new Rx.BehaviorSubject null
    @hasText = new Rx.BehaviorSubject false

    @$conversationImagePreview = new ConversationImagePreview {
      @imageData
      @overlay$
      @model
      onUpload: ({key, width, height}) =>
        @message.onNext "![](local://#{key} =#{width}x#{height})"
        @postMessage()
    }

    @currentPanel = new Rx.BehaviorSubject 'text'

    @panels =
      text: {
        $icon: new Icon()
        icon: 'text'
        $el: new ConversationInputTextarea {
          onPost: @post
          @onFocus
          @message
          @isTextareaFocused
          @hasText
          @model
        }
      }
      stickers: {
        $icon: new Icon()
        icon: 'stickers'
        $el: new ConversationInputStickers {
          onPost: @post
          @message
        }
      }
      image: {
        $icon: new Icon()
        icon: 'image'
        onclick: -> null
        $uploadOverlay: new UploadOverlay {@model}
      }
      gifs: {
        $icon: new Icon()
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

  post: =>
    @onPost()
    @message.onNext ''
    @hasText.onNext false

  render: =>
    {currentPanel} = @state.getValue()

    z '.z-conversation-input', {
      className: z.classKebab {"is-#{currentPanel}-panel": true}
    },
      z '.g-grid',
        @panels[currentPanel].$el

        z '.bottom-icons', [
          _map @panels, ({$icon, icon, onclick, $uploadOverlay}, panel) =>
            z '.icon',
              z $icon, {
                onclick: onclick or =>
                  @currentPanel.onNext panel
                icon: icon
                color: if currentPanel is panel \
                       then colors.$white
                       else colors.$white30
                isTouchTarget: true
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
