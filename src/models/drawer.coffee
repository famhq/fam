z = require 'zorium'
Rx = require 'rx-lite'

module.exports = class Drawer
  constructor: ->
    console.log 'drawer ocns'
    @_isOpen = new Rx.ReplaySubject false

  isOpen: =>
    @_isOpen

  open: =>
    console.log 'set true'
    @_isOpen.onNext true
    # prevent body scrolling while viewing menu
    document.body.style.overflow = 'hidden'

  close: =>
    @_isOpen.onNext false
    document.body.style.overflow = 'auto'
