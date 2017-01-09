z = require 'zorium'
FloatingActionButton = require 'zorium-paper/floating_action_button'

Icon = require '../icon'
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class ConversationImagePreview
  constructor: ({@imageData, @model, @overlay$, @onUpload}) ->
    @$sendIcon = new Icon()
    @$closeImagePreviewIcon = new Icon()
    @$uploadImageFab = new FloatingActionButton()
    @$uploadIcon = new Icon()

    @state = z.state
      imageData: @imageData
      isUploading: false
      windowSize: @model.window.getSize()

  render: =>
    {imageData, isUploading, windowSize} = @state.getValue()

    imageData ?= {}

    imageAspectRatio = imageData.width / imageData.height
    windowAspectRatio = windowSize.widht / windowSize.height
    # 3:1, 1:1
    if imageAspectRatio > windowAspectRatio
      previewWidth = Math.min windowSize.widht, imageData.width
      previewHeight = previewWidth / imageAspectRatio
    else
      previewHeight = Math.min windowSize.height, imageData.height
      previewWidth = previewHeight * imageAspectRatio

    z '.z-conversation-image-preview',
      z 'img',
        src: imageData.dataUrl
        width: previewWidth
        height: previewHeight
      z '.close',
        z @$closeImagePreviewIcon,
          icon: 'close'
          color: colors.$white
          isTouchTarget: true
          onclick: =>
            @imageData.onNext null
            @overlay$.onNext null
      z '.fab',
        z @$uploadImageFab,
          colors:
            c500: colors.$primary500
          $icon: z @$uploadIcon, {
            icon: if isUploading then 'ellipsis' else 'send'
            isTouchTarget: false
            color: colors.$white
          }
          onclick: =>
            unless isUploading
              @state.set isUploading: true
              @model.chatMessage.uploadImage imageData.file
              .then ({smallUrl, largeUrl, key}) =>
                @onUpload arguments[0]
                @state.set isUploading: false
                @imageData.onNext null
                @overlay$.onNext null
