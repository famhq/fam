_ = require 'lodash'
Rx = require 'rx-lite'
Exoid = require 'exoid'
request = require 'clay-request'

Auth = require './auth'
User = require './user'
UserData = require './user_data'
Drawer = require './drawer'
Conversation = require './conversation'
ClashRoyaleDeck = require './clash_royale_deck'
ClashRoyaleUserDeck = require './clash_royale_user_deck'
ClashRoyaleCard = require './clash_royale_card'
ChatMessage = require './chat_message'
Group = require './group'
Product = require './product'
PushToken = require './push_token'
Thread = require './thread'
ThreadMessage = require './thread_message'

Portal = require './portal'
config = require '../config'

SERIALIZATION_KEY = 'MODEL'
SERIALIZATION_EXPIRE_TIME_MS = 1000 * 10 # 10 seconds

module.exports = class Model
  constructor: ({cookieSubject, serverHeaders, io}) ->
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

    ioEmit = (event, opts) ->
      accessToken.take(1).toPromise()
      .then (accessToken) ->
        io.emit event, _.defaults {accessToken}, opts

    proxy = (url, opts) ->
      accessToken.take(1).toPromise()
      .then (accessToken) ->
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
      ioEmit: ioEmit
      io: io
      cache: cache.exoid

    @auth = new Auth {@exoid, cookieSubject}
    @user = new User {@auth, proxy, @exoid}
    @userData = new UserData {@auth}
    @chatMessage = new ChatMessage {@auth}
    @conversation = new Conversation {@auth}
    @clashRoyaleDeck = new ClashRoyaleDeck {@auth}
    @clashRoyaleUserDeck = new ClashRoyaleUserDeck {@auth}
    @clashRoyaleCard = new ClashRoyaleCard {@auth}
    @group = new Group {@auth}
    @thread = new Thread {@auth}
    @threadMessage = new ThreadMessage {@auth}
    @product = new Product {@auth}
    @pushToken = new PushToken {@auth}
    @drawer = new Drawer()
    @portal = new Portal {@user, @game, @modal}

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
