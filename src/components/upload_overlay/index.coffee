z = require 'zorium'
Rx = require 'rx-lite'
colors = require '../../colors'
log = require 'loga'
Environment = require 'clay-environment'

config = require '../../config'

if window?
  require './index.styl'

dataUrlToBlob = (dataUrl) ->
  # kik adding extra quotes for whatever reason
  dataUrl = dataUrl.replace /"/g, ''
  binary = atob(dataUrl.split(',')[1])
  byteArray = []
  for i in [0..binary.length]
    byteArray.push binary.charCodeAt(i)
  mimeString = dataUrl.split(',')[0].split(':')[1].split(';')[0]
  return new Blob([new Uint8Array(byteArray)], {type: mimeString})

module.exports = class UploadOverlay
  constructor: ({@model}) ->
    @state = z.state
      platform: Environment.getPlatform {gameKey: config.GAME_KEY}

  render: ({onSelect}) =>
    {platform} = @state.getValue()

    z '.z-upload-overlay',
      if platform is 'kik'
        z '.overlay',
          onclick: =>
            @model.portal.call 'kik.photo.get', [{}]
            .then (photos) ->
              dataUrl = photos[0]
              file = dataUrlToBlob(dataUrl)
              onSelect {file, dataUrl}
      else
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
