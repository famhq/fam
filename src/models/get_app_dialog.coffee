Rx = require 'rxjs'

module.exports = class GetAppDialog
  constructor: ->
    @_isOpen = new Rx.BehaviorSubject false

  isOpen: =>
    @_isOpen

  open: =>
    @_isOpen.next true
    # prevent body scrolling while viewing menu
    document.body.style.overflow = 'hidden'

  close: =>
    @_isOpen.next false
    document.body.style.overflow = 'auto'
