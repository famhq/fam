_ = require 'lodash'
Rx = require 'rx-lite'
Exoid = require 'exoid'
request = require 'clay-request'

Auth = require './auth'
User = require './user'
UserData = require './user_data'
Drawer = require './drawer'
Conversation = require './conversation'
ChatMessage = require './chat_message'
Thread = require './thread'

Portal = require './portal'
config = require '../config'

SERIALIZATION_KEY = 'MODEL'
SERIALIZATION_EXPIRE_TIME_MS = 1000 * 10 # 10 seconds

module.exports = class Model
  constructor: ({cookieSubject, serverHeaders}) ->
    serverHeaders ?= {}

    serialization = window?[SERIALIZATION_KEY] or {}
    isExpired = if serialization.expires?
      # Because of potential clock skew we check around the value
      delta = Math.abs(Date.now() - serialization.expires)
      delta > SERIALIZATION_EXPIRE_TIME_MS
    else
      true
    cache = if isExpired then {} else serialization
    @isFromCache = not _.isEmpty cache

    accessToken = cookieSubject.map (cookies) ->
      cookies[config.AUTH_COOKIE]

    proxy = (url, opts) ->
      accessToken.take(1).toPromise()
      .then (accessToken) ->
        proxyHeaders =  _.pick serverHeaders, [
          'cookie'
          'user-agent'
          'accept-language'
          'x-forwarded-for'
        ]
        request url, _.merge {
          qs: if accessToken? then {accessToken} else {}
          headers: if _.isPlainObject opts?.body
            _.merge {
              # Avoid CORS preflight
              'Content-Type': 'text/plain'
            }, proxyHeaders
          else
            proxyHeaders
        }, opts

    @exoid = new Exoid
      api: config.API_URL + '/exoid'
      fetch: proxy
      cache: cache.exoid

    @auth = new Auth({@exoid, cookieSubject})
    @user = new User({@auth, proxy, @exoid})
    @userData = new UserData({@auth})
    @chatMessage = new ChatMessage({@auth})
    @conversation = new Conversation({@auth})
    @thread = new Thread({@auth})
    @drawer = new Drawer()
    @portal = new Portal({@user, @game, @modal})

  wasCached: => @isFromCache

  getSerializationStream: =>
    Rx.Observable.combineLatest [
      @exoid.getCacheStream()
    ], (results...) -> results
    .map ([exoidCache]) ->
      string = JSON.stringify {
        exoid: exoidCache
        expires: Date.now() + SERIALIZATION_EXPIRE_TIME_MS
      }
      "window['#{SERIALIZATION_KEY}']=#{string};"
