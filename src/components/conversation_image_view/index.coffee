z = require 'zorium'

Icon = require '../icon'
ButtonBack = require '../button_back'
AppBar = require '../app_bar'
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class ConversationImageView
  constructor: ({@model, @imageData, @overlay$, @router}) ->
    @$buttonBack = new ButtonBack {@router}
    @$appBar = new AppBar {@model}

    @state = z.state
      imageData: @imageData
      windowSize: @model.window.getSize()

  render: =>
    {windowSize, imageData} = @state.getValue()

    imageData ?= {}

    windowHeight = windowSize.height - @$appBar.getHeight()
    imageAspectRatio = imageData.aspectRatio
    windowAspectRatio = windowSize.width / windowHeight
    # 3:1, 1:1
    if imageAspectRatio > windowAspectRatio
      imageWidth = windowSize.width
      imageHeight = imageWidth / imageAspectRatio
    else
      imageHeight = windowHeight
      imageWidth = imageHeight * imageAspectRatio

    z '.z-conversation-image-view',
      z @$appBar, {
        title: 'Image'
        $topLeftButton: z @$buttonBack, {
          onclick: =>
            @imageData.onNext null
            @overlay$.onNext null
        }
      }
      z 'img',
        src: imageData.url
        width: imageWidth
        height: imageHeight
