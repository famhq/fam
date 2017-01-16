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

  getAppBarHeight: =>
    if @getSize().getValue().width > 768 then 64 else 56

  pauseResizing: =>
    @isPaused = true

  resumeResizing: =>
    @isPaused = false
    @updateSize()
