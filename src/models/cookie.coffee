_defaults = require 'lodash/defaults'
require 'rxjs/add/operator/take'
require 'rxjs/add/operator/toPromise'

config = require '../config'

COOKIE_DURATION_MS = 365 * 24 * 3600 * 1000 # 1 year
ONE_DAY_MS = 3600 * 24 * 1000

class Cookie
  constructor: ({@cookieSubject}) ->
    # can't be run at same time since cookieSubject.take and next are async
    @setQueue = []
    @setQueueInterval = null
    @set = =>
      args = arguments
      @setQueue.push =>
        @_set args...
      unless @setQueueInterval
        @setQueueInterval = setInterval @processSetQueue, 1

  processSetQueue: =>
    @setQueue.shift()?()
    if @setQueue.length is 0
      clearInterval @setQueueInterval
      @setQueueInterval = null


  getCookieOpts: (host, key) ->
    host ?= config.HOST
    hostname = host.split(':')[0]

    path: '/'
    expires: if key is 'isPushTokenStored' \
             then new Date(Date.now() + ONE_DAY_MS)
             else new Date(Date.now() + COOKIE_DURATION_MS)
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
