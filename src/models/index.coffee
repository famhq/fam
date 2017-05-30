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
UserGroupData = require './user_group_data'
Player = require './player'
Clan = require './clan'
ClanRecordType = require './clan_record_type'
ClashRoyaleAPI = require './clash_royale_api'
ClashRoyaleDeck = require './clash_royale_deck'
ClashRoyaleUserDeck = require './clash_royale_user_deck'
ClashRoyaleCard = require './clash_royale_card'
ChatMessage = require './chat_message'
Conversation = require './conversation'
DynamicImage = require './dynamic_image'
Event = require './event'
Gif = require './gif'
Group = require './group'
GroupRecord = require './group_record'
GroupRecordType = require './group_record_type'
GameRecordType = require './game_record_type'
Language = require './language'
Mod = require './mod'
Product = require './product'
PushToken = require './push_token'
Stream = require './stream'
Thread = require './thread'
ThreadComment = require './thread_comment'
Video = require './video'
Drawer = require './drawer'
GetAppDialog = require './get_app_dialog'
SignInDialog = require './sign_in_dialog'
PushNotificationSheet = require './push_notification_sheet'
InstallOverlay = require './install_overlay'
ImageViewOverlay = require './image_view_overlay'
Window = require './window'

config = require '../config'

SERIALIZATION_KEY = 'MODEL'
SERIALIZATION_EXPIRE_TIME_MS = 1000 * 10 # 10 seconds

module.exports = class Model
  constructor: ({cookieSubject, serverHeaders, io, @portal}) ->
    serverHeaders ?= {}

    cache = window?[SERIALIZATION_KEY] or {}
    # isExpired = if serialization.expires?
    #   # Because of potential clock skew we check around the value
    #   delta = Math.abs(Date.now() - serialization.expires)
    #   delta > SERIALIZATION_EXPIRE_TIME_MS
    # else
    #   true
    # cache = if isExpired then {} else serialization
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
      isServerSide: not window?

    pushToken = new Rx.BehaviorSubject null

    @auth = new Auth {@exoid, cookieSubject, pushToken}
    @user = new User {@auth, proxy, @exoid, cookieSubject}
    @userData = new UserData {@auth}
    @userGroupData = new UserGroupData {@auth}
    @player = new Player {@auth}
    @clan = new Clan {@auth}
    @dynamicImage = new DynamicImage {@auth}
    @chatMessage = new ChatMessage {@auth, proxy, @exoid}
    @conversation = new Conversation {@auth}
    @clanRecordType = new ClanRecordType {@auth}
    @clashRoyaleAPI = new ClashRoyaleAPI {@auth}
    @clashRoyaleDeck = new ClashRoyaleDeck {@auth}
    @clashRoyaleUserDeck = new ClashRoyaleUserDeck {@auth}
    @clashRoyaleCard = new ClashRoyaleCard {@auth}
    @event = new Event {@auth}
    @gif = new Gif()
    @group = new Group {@auth}
    @groupRecord = new GroupRecord {@auth}
    @groupRecordType = new GroupRecordType {@auth}
    @gameRecordType = new GameRecordType {@auth}
    @thread = new Thread {@auth}
    @threadComment = new ThreadComment {@auth}
    @mod = new Mod {@auth}
    @product = new Product {@auth}
    @pushToken = new PushToken {@auth, pushToken}
    @stream = new Stream {@auth}
    @video = new Video {@auth}
    @drawer = new Drawer()
    @signInDialog = new SignInDialog()
    @getAppDialog = new GetAppDialog()
    @installOverlay = new InstallOverlay()
    @imageViewOverlay = new ImageViewOverlay()
    @pushNotificationSheet = new PushNotificationSheet()
    @portal?.setModels {@user, @game, @modal, @installOverlay, @getAppDialog}
    @window = new Window {cookieSubject}


    # expNativeLanguageGroup = localStorage?['exp:nativeLanguage']
    # unless expNativeLanguageGroup
    #   expNativeLanguageGroup = if Math.random() > 0.5 \
    #                            then 'native'
    #                            else 'control'
    #   localStorage?['exp:nativeLanguage'] = expNativeLanguageGroup
    # ga? 'send', 'event', 'exp', 'nativeLanguage', expNativeLanguageGroup

    language = window?.navigator?.languages?[0] or window?.navigator?.language
    browserLanugage = language?.split?('-')[0]
    if browserLanugage in ['es', 'it', 'fr'] # and expNativeLanguageGroup is 'native'
      language = browserLanugage
    else
      language = 'en'

    @l = new Language {language}

    # if expNativeLanguageGroup is 'native'
    @user.getMe().take(1).toPromise()
    .then (me) =>
      if me.country in [
        'AR', 'BO', 'CR', 'CU', 'DM', 'EC', 'SV', 'GQ', 'GT', 'HN', 'MX'
        'NI', 'PA', 'PE', 'ES', 'UY', 'VE'
      ]
        @l.setLanguage 'es'
      else if me.country is 'IT'
        @l.setLanguage 'it'
      else if me.country is 'FR'
        @l.setLanguage 'fr'

  wasCached: => @isFromCache

  getSerializationStream: =>
    @exoid.getCacheStream()
    .map (exoidCache) ->
      string = JSON.stringify({
        exoid: exoidCache
        # problem with this is clock skew
        # expires: Date.now() + SERIALIZATION_EXPIRE_TIME_MS
      }).replace /<\/script/gi, '<\\/script'
      "window['#{SERIALIZATION_KEY}']=#{string};"
