Rx = require 'rx-lite'
Exoid = require 'exoid'
request = require 'clay-request'
_isEmpty = require 'lodash/isEmpty'
_isPlainObject = require 'lodash/isPlainObject'
_defaults = require 'lodash/defaults'
_merge = require 'lodash/merge'
_pick = require 'lodash/pick'

Auth = require './auth'
User = require './user'
UserData = require './user_data'
Drawer = require './drawer'
Conversation = require './conversation'
ClashRoyaleDeck = require './clash_royale_deck'
ClashRoyaleUserDeck = require './clash_royale_user_deck'
ClashRoyaleCard = require './clash_royale_card'
ChatMessage = require './chat_message'
Event = require './event'
Gif = require './gif'
Group = require './group'
GroupRecord = require './group_record'
GroupRecordType = require './group_record_type'
GroupUserData = require './group_user_data'
Product = require './product'
PushToken = require './push_token'
Thread = require './thread'
SignInDialog = require './sign_in_dialog'
ThreadComment = require './thread_comment'
Window = require './window'

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
    @isFromCache = not _isEmpty cache

    accessToken = cookieSubject.map (cookies) ->
      cookies[config.AUTH_COOKIE]

    ioEmit = (event, opts) ->
      accessToken.take(1).toPromise()
      .then (accessToken) ->
        io.emit event, _defaults {accessToken}, opts

    proxy = (url, opts) ->
      accessToken.take(1).toPromise()
      .then (accessToken) ->
        proxyHeaders =  _pick serverHeaders, [
          'cookie'
          'user-agent'
          'accept-language'
          'x-forwarded-for'
        ]
        request url, _merge {
          qs: if accessToken? then {accessToken} else {}
          headers: if _isPlainObject opts?.body
            _merge {
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

    pushToken = new Rx.BehaviorSubject null

    @auth = new Auth {@exoid, cookieSubject, pushToken}
    @user = new User {@auth, proxy, @exoid}
    @userData = new UserData {@auth}
    @chatMessage = new ChatMessage {@auth, proxy, @exoid}
    @conversation = new Conversation {@auth}
    @clashRoyaleDeck = new ClashRoyaleDeck {@auth}
    @clashRoyaleUserDeck = new ClashRoyaleUserDeck {@auth}
    @clashRoyaleCard = new ClashRoyaleCard {@auth}
    @event = new Event {@auth}
    @gif = new Gif()
    @group = new Group {@auth}
    @groupRecord = new GroupRecord {@auth}
    @groupRecordType = new GroupRecordType {@auth}
    @groupUserData = new GroupUserData {@auth}
    @thread = new Thread {@auth}
    @threadComment = new ThreadComment {@auth}
    @product = new Product {@auth}
    @pushToken = new PushToken {@auth, pushToken}
    @drawer = new Drawer()
    @signInDialog = new SignInDialog()
    @portal = new Portal {@user, @game, @modal}
    @window = new Window()

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
