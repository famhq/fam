z = require 'zorium'
Environment = require '../../services/environment'

config = require '../../config'

if window?
  require './index.styl'

MAX_WIDTH_PX = 700
PADDING_PX = 16

module.exports = class EmbeddedVideo
  constructor: ({@model, src}) ->
    unless src.map
      @src = src
    @state = z.state
      windowSize: @model.window.getSize()
      src: @src

  render: =>
    {windowSize, src} = @state.getValue()
    width = Math.min MAX_WIDTH_PX, windowSize.width - PADDING_PX * 2
    height = width * (9 / 16)
    isNativeApp = Environment.isNativeApp config.GAME_KEY

    z '.z-embedded-video',
      if isNativeApp
        z '.thumbnail', {
          onclick: =>
            @model.portal.call 'browser.openWindow', {
              url: src
              target: '_system'
            }
        },
          z 'img', {
            width
            height
            src: 'https://img.youtube.com/vi/nnkBzktQuM0/hqdefault.jpg'
          }
          z '.play'
      else
        z 'iframe',
          width: width
          height: height
          src: @src or src
          frameborder: 0
          allow: 'autoplay; encrypted-media'
          allowfullscreen: true
          webkitallowfullscreen: true
