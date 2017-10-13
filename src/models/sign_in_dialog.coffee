Rx = require 'rxjs'

module.exports = class SignInDialog
  constructor: ->
    @_isOpen = new Rx.BehaviorSubject false
    @_mode = new Rx.BehaviorSubject 'join'
    @onLoggedInFn = null

  isOpen: =>
    @_isOpen

  onLoggedIn: (@onLoggedInFn) => null

  loggedIn: =>
    @onLoggedInFn?()

  openIfGuest: (user) =>
    new Promise (resolve, reject) =>
      if user?.isMember
        resolve true
      else
        @open()
        @onLoggedIn resolve

  getMode: =>
    @_mode

  setMode: (mode) =>
    @_mode.next mode

  open: (mode) =>
    mode ?= 'join'
    @setMode mode
    @_isOpen.next true
    # prevent body scrolling while viewing menu
    document.body.style.overflow = 'hidden'

  close: =>
    @_isOpen.next false
    @onLoggedIn null
    document.body.style.overflow = 'auto'
