_defaults = require 'lodash/defaults'
_pick = require 'lodash/pick'
Rx = require 'rx-lite'

config = require '../config'

module.exports = class Auth
  constructor: ({@exoid, @cookieSubject, @pushToken}) ->
    initPromise = null
    @waitValidAuthCookie = Rx.Observable.defer =>
      if initPromise?
        return initPromise
      return initPromise = @cookieSubject.take(1).toPromise()
      .then (currentCookies) =>
        (if currentCookies[config.AUTH_COOKIE]?
          @exoid.getCached 'users.getMe'
          .then (user) =>
            if user?
              return {accessToken: currentCookies[config.AUTH_COOKIE]}
            @exoid.call 'users.getMe'
            .then ->
              return {accessToken: currentCookies[config.AUTH_COOKIE]}
          .catch =>
            # @cookieSubject.onNext _defaults {
            #   "#{config.AUTH_COOKIE}": null
            # }, currentCookies
            @exoid.call 'auth.login'
        else
          @exoid.call 'auth.login')
        .then ({accessToken}) =>
          @setAccessToken accessToken

  setAccessToken: (accessToken) =>
    @cookieSubject.take(1).toPromise()
    .then (currentCookies) =>
      @cookieSubject.onNext _defaults {
        "#{config.AUTH_COOKIE}": accessToken
      }, currentCookies

  logout: =>
    @setAccessToken ''
    @exoid.call 'auth.login'
    .then ({accessToken}) =>
      @setAccessToken accessToken
    .then =>
      @exoid.invalidateAll()

  join: ({email, username, password} = {}) =>
    @exoid.call 'auth.join', {email, username, password}
    .then ({username, accessToken}) =>
      @setAccessToken accessToken
      .then =>
        @exoid.invalidateAll()

  afterLogin: ({accessToken}) =>
    @setAccessToken accessToken
    .then =>
      @exoid.invalidateAll()
      # give time to set accessToken, I don't think it's sync (onNext)
      setTimeout =>
        pushToken = @pushToken.getValue()
        if pushToken
          @call 'pushTokens.updateByToken', {token: pushToken}
          .catch -> null

  login: ({username, password} = {}) =>
    @exoid.call 'auth.loginUsername', {username, password}
    .then @afterLogin

  loginFacebook: ({facebookAccessToken, isLoginOnly} = {}) =>
    cookieAccessToken = @cookieSubject.getValue()[config.AUTH_COOKIE]

    (if facebookAccessToken
    then Promise.resolve {facebookAccessToken}
    else @portal.call 'facebook.login'
    )
    .then ({status, facebookAccessToken}) =>
      @exoid.call 'auth.loginFacebook', {isLoginOnly, facebookAccessToken}
    .then @afterLogin

  stream: (path, body, options = {}) =>
    options = _pick options, [
      'isErrorable', 'clientChangesStream', 'ignoreCache', 'initialSortFn'
      'isStreamed', 'limit'
    ]
    @waitValidAuthCookie
    .flatMapLatest =>
      @exoid.stream path, body, options

  call: (path, body, {invalidateAll, invalidateSingle} = {}) =>
    @waitValidAuthCookie.take(1).toPromise()
    .then =>
      @exoid.call path, body
    .then (response) =>
      if invalidateAll
        console.log 'Invalidating all'
        @exoid.invalidateAll()
      else if invalidateSingle
        console.log 'Invalidating single', invalidateSingle
        @exoid.invalidate invalidateSingle
      response
