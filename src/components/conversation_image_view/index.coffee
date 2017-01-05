z = require 'zorium'

Icon = require '../icon'
ButtonBack = require '../button_back'
AppBar = require '../app_bar'
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class ConversationImageView
  constructor: ({@imageData, @overlay$, @router}) ->
    @$buttonBack = new ButtonBack {@router}
    @$appBar = new AppBar {@model}

    @state = z.state
      imageData: @imageData

  render: =>
    {imageData} = @state.getValue()

    imageData ?= {}

    imageAspectRatio = imageData.aspectRatio
    windowAspectRatio = window?.innerWidth / window?.innerHeight
    # 3:1, 1:1
    if imageAspectRatio > windowAspectRatio
      imageWidth = window?.innerWidth
      imageHeight = imageWidth / imageAspectRatio
    else
      imageHeight = window?.innerHeight
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
