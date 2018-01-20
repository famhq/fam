_defaults = require 'lodash/defaults'
_throttle = require 'lodash/throttle'
require 'rxjs/add/operator/take'
require 'rxjs/add/operator/toPromise'

config = require '../config'

COOKIE_DURATION_MS = 365 * 24 * 3600 * 1000 # 1 year

class Cookie
  constructor: ({@cookieSubject}) ->
    # can't be run at same time since cookieSubject.take and onNext are async
    @set = _throttle @_set, 100

  getCookieOpts: (host) ->
    host ?= config.HOST
    hostname = host.split(':')[0]

    path: '/'
    expires: new Date(Date.now() + COOKIE_DURATION_MS)
    # Set cookie for subdomains
    domain: '.' + hostname

  _set: (key, value) =>
    @cookieSubject.take(1).toPromise()
    .then (currentCookies) =>
      @cookieSubject.next _defaults {
        "#{key}": value
      }, currentCookies

  get: (key) =>
    cookies = @cookieSubject.getValue()
    cookies[key]

module.exports = Cookie
