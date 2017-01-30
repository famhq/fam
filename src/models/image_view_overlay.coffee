Rx = require 'rx-lite'

module.exports = class ImageViewOverlay
  constructor: ->
    @imageData = new Rx.BehaviorSubject null

  getImageData: =>
    @imageData

  setImageData: (imageData) =>
    @imageData.onNext imageData
