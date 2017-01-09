Rx = require 'rx-lite'

module.exports = class Window
  constructor: ->
    @isPaused = false

    @size = new Rx.BehaviorSubject {
      width: window?.innerWidth
      height: window?.innerHeight
    }
    window?.addEventListener 'resize', @updateSize

  updateSize: =>
    unless @isPaused
      @size.onNext {
        width: window?.innerWidth
        height: window?.innerHeight
      }

  getSize: =>
    @size

  pauseResizing: =>
    @isPaused = true

  resumeResizing: =>
    @isPaused = false
    @updateSize()
