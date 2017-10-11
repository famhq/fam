_defaults = require 'lodash/defaults'

config = require '../config'

COOKIE_DURATION_MS = 365 * 24 * 3600 * 1000 # 1 year

class CookieService
  getCookieOpts: (host) ->
    host ?= config.HOST
    hostname = host.split(':')[0]

    path: '/'
    expires: new Date(Date.now() + COOKIE_DURATION_MS)
    # Set cookie for subdomains
    domain: '.' + hostname

  set: (cookieSubject, key, value) ->
    cookieSubject.take(1).toPromise()
    .then (currentCookies) ->
      cookieSubject.onNext _defaults {
        "#{key}": value
      }, currentCookies

  get: (cookieSubject, key) ->
    cookies = cookieSubject.getValue()
    cookies[key]

module.exports = new CookieService()
