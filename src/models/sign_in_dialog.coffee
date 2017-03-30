Rx = require 'rx-lite'

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
        resolve()
      else
        @open()
        @onLoggedIn resolve

  getMode: =>
    @_mode

  setMode: (mode) =>
    @_mode.onNext mode

  open: (mode) =>
    mode ?= 'join'
    @setMode mode
    @_isOpen.onNext true
    # prevent body scrolling while viewing menu
    document.body.style.overflow = 'hidden'

  close: =>
    @_isOpen.onNext false
    @onLoggedIn null
    document.body.style.overflow = 'auto'
