Rx = require 'rxjs'

module.exports = class ImageViewOverlay
  constructor: ->
    @imageData = new Rx.BehaviorSubject null

  getImageData: =>
    @imageData

  setImageData: (imageData) =>
    @imageData.next imageData
