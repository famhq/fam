Exoid = require 'exoid'
request = require 'clay-request'
_isEmpty = require 'lodash/isEmpty'
_isPlainObject = require 'lodash/isPlainObject'
_defaults = require 'lodash/defaults'
_merge = require 'lodash/merge'
_pick = require 'lodash/pick'
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject
require 'rxjs/add/operator/take'

Auth = require './auth'
Player = require './player'
Ad = require './ad'
Addon = require './addon'
Clan = require './clan'
ClanRecordType = require './clan_record_type'
ClashRoyaleAPI = require './clash_royale_api'
ClashRoyaleDeck = require './clash_royale_deck'
ClashRoyalePlayerDeck = require './clash_royale_player_deck'
ClashRoyaleCard = require './clash_royale_card'
ClashRoyaleMatch = require './clash_royale_match'
ChatMessage = require './chat_message'
Conversation = require './conversation'
DynamicImage = require './dynamic_image'
Event = require './event'
Experiment = require './experiment'
Gif = require './gif'
Group = require './group'
GroupUser = require './group_user'
GroupRecord = require './group_record'
GroupRecordType = require './group_record_type'
GameRecordType = require './game_record_type'
Language = require './language'
Mod = require './mod'
Nps = require './nps'
Payment = require './payment'
Product = require './product'
PushToken = require './push_token'
Reward = require './reward'
Star = require './star'
Stream = require './stream'
Thread = require './thread'
ThreadComment = require './thread_comment'
ThreadVote = require './thread_vote'
User = require './user'
UserData = require './user_data'
UserFollower = require './user_follower'
UserGroupData = require './user_group_data'
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
  constructor: ({cookieSubject, serverHeaders, io, @portal, language}) ->
    serverHeaders ?= {}

    cache = window?[SERIALIZATION_KEY] or {}
    window?[SERIALIZATION_KEY] = null
    # maybe this means less memory used for long caches?
    document?.querySelector('.model')?.innerHTML = ''

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

    pushToken = new RxBehaviorSubject null

    @l = new Language {language, cookieSubject}

    @auth = new Auth {@exoid, cookieSubject, pushToken}
    @user = new User {@auth, proxy, @exoid, cookieSubject}
    @userData = new UserData {@auth}
    @userFollower = new UserFollower {@auth}
    @userGroupData = new UserGroupData {@auth}
    @player = new Player {@auth}
    @ad = new Ad {@portal}
    @addon = new Addon {@auth, @l}
    @clan = new Clan {@auth}
    @dynamicImage = new DynamicImage {@auth}
    @chatMessage = new ChatMessage {@auth, proxy, @exoid}
    @conversation = new Conversation {@auth}
    @clanRecordType = new ClanRecordType {@auth}
    @clashRoyaleAPI = new ClashRoyaleAPI {@auth}
    @clashRoyaleDeck = new ClashRoyaleDeck {@auth}
    @clashRoyalePlayerDeck = new ClashRoyalePlayerDeck {@auth}
    @clashRoyaleCard = new ClashRoyaleCard {@auth, @l}
    @clashRoyaleMatch = new ClashRoyaleMatch {@auth}
    @event = new Event {@auth}
    @experiment = new Experiment()
    @gif = new Gif()
    @group = new Group {@auth}
    @groupUser = new GroupUser {@auth}
    @groupRecord = new GroupRecord {@auth}
    @groupRecordType = new GroupRecordType {@auth}
    @gameRecordType = new GameRecordType {@auth}
    @thread = new Thread {@auth, @l}
    @threadComment = new ThreadComment {@auth}
    @threadVote = new ThreadVote {@auth}
    @mod = new Mod {@auth}
    @nps = new Nps {@auth}
    @payment = new Payment {@auth}
    @product = new Product {@auth}
    @pushToken = new PushToken {@auth, pushToken}
    @reward = new Reward {@auth}
    @star = new Star {@auth}
    @stream = new Stream {@auth}
    @video = new Video {@auth}
    @drawer = new Drawer()
    @signInDialog = new SignInDialog()
    @getAppDialog = new GetAppDialog()
    @installOverlay = new InstallOverlay()
    @imageViewOverlay = new ImageViewOverlay()
    @pushNotificationSheet = new PushNotificationSheet()
    @portal?.setModels {
      @user, @game, @player, @clan, @clashRoyaleMatch, @clashRoyalePlayerDeck,
      @clanRecordType, @gameRecordType, @modal, @installOverlay, @getAppDialog

    }
    @window = new Window {cookieSubject, @experiment}

    # if expNativeLanguageGroup is 'native'
    @user.getMe().take(1).toPromise()
    # .then (me) =>
    #   if me.country in [
    #     'AR', 'BO', 'CR', 'CU', 'DM', 'EC', 'SV', 'GQ', 'GT', 'HN', 'MX'
    #     'NI', 'PA', 'PE', 'ES', 'UY', 'VE'
    #   ]
    #     @l.setLanguage 'es'
    #   else if me.country is 'IT'
    #     @l.setLanguage 'it'
    #   else if me.country is 'BR'
    #     @l.setLanguage 'pt'
    #   else if me.country is 'FR'
    #     @l.setLanguage 'fr'

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
