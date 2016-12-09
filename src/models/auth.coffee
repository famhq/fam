_ = require 'lodash'
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
            # @cookieSubject.onNext _.defaults {
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
      @cookieSubject.onNext _.defaults {
        "#{config.AUTH_COOKIE}": accessToken
      }, currentCookies

  join: ({email, username, password} = {}) =>
    @exoid.call 'auth.join', {email, username, password}
    .then ({username, accessToken}) =>
      @setAccessToken accessToken
      .then =>
        @exoid.invalidateAll()

  login: ({username, password} = {}) =>
    @exoid.call 'auth.loginUsername', {username, password}
    .then ({username, accessToken}) =>
      console.log 'logged in', username, accessToken
      @setAccessToken accessToken
      .then =>
        @exoid.invalidateAll()
        # give time to set accessToken, I don't think it's sync (onNext)
        setTimeout =>
          pushToken = @pushToken.getValue()
          if pushToken
            @call 'pushTokens.updateByToken', {token: pushToken}
            .catch -> null

  loginByCode: ({code, username, password} = {}) =>
    @exoid.call 'auth.loginCode', {code, username, password}
    .then ({accessToken}) =>
      @setAccessToken accessToken
      .then =>
        @exoid.invalidateAll()
        # give time to set accessToken, I don't think it's sync (onNext)
        setTimeout =>
          pushToken = @pushToken.getValue()
          if pushToken
            @call 'pushTokens.updateByToken', {token: pushToken}
            .catch -> null

  stream: (path, body, {ignoreCache, isErrorable} = {}) =>
    if ignoreCache
      body = _.defaults {rand: ignoreCache}, body
    @waitValidAuthCookie
    .flatMapLatest =>
      @exoid.stream path, body, {isErrorable, ignoreCache: Boolean ignoreCache}

  call: (path, body, {invalidateAll} = {}) =>
    @waitValidAuthCookie.take(1).toPromise()
    .then =>
      @exoid.call path, body
    .then (response) =>
      if invalidateAll
        @exoid.invalidateAll()
      response
