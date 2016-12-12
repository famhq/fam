z = require 'zorium'
Environment = require 'clay-environment'

config = require '../../config'

if window?
  require './index.styl'

module.exports = class UploadOverlay
  constructor: ({@model}) ->
    @state = z.state
      platform: Environment.getPlatform {gameKey: config.GAME_KEY}

  render: ({onSelect}) =>
    {platform} = @state.getValue()

    z '.z-upload-overlay',
      z 'input#image.overlay',
        type: 'file'
        onchange: (e) ->
          e?.preventDefault()
          $$imageInput = document.getElementById('image')
          file = $$imageInput?.files[0]

          if file
            reader = new FileReader()
            reader.onload = (e) ->
              onSelect? {
                file: file
                dataUrl: e.target.result
              }

            reader.readAsDataURL file
