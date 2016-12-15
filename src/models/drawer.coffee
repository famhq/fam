Rx = require 'rx-lite'

module.exports = class Drawer
  constructor: ->
    @_isOpen = new Rx.BehaviorSubject false

  isOpen: =>
    @_isOpen

  open: =>
    @_isOpen.onNext true
    # prevent body scrolling while viewing menu
    document.body.style.overflow = 'hidden'

  close: =>
    @_isOpen.onNext false
    document.body.style.overflow = 'auto'
