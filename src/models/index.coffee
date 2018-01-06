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
Ban = require './ban'
Clan = require './clan'
ClanRecordType = require './clan_record_type'
ClashRoyaleAPI = require './clash_royale_api'
ClashRoyaleDeck = require './clash_royale_deck'
ClashRoyalePlayerDeck = require './clash_royale_player_deck'
ClashRoyaleCard = require './clash_royale_card'
ClashRoyaleMatch = require './clash_royale_match'
ChatMessage = require './chat_message'
Conversation = require './conversation'
Cookie = require './cookie'
DynamicImage = require './dynamic_image'
Event = require './event'
Experiment = require './experiment'
Gif = require './gif'
Group = require './group'
GroupAuditLog = require './group_audit_log'
GroupUser = require './group_user'
GroupUserXpTransaction = require './group_user_xp_transaction'
GroupRecord = require './group_record'
GroupRecordType = require './group_record_type'
GroupRole = require './group_role'
GameRecordType = require './game_record_type'
Image = require './image'
Item = require './item'
Language = require './language'
Nps = require './nps'
Payment = require './payment'
Product = require './product'
PushToken = require './push_token'
Reward = require './reward'
SpecialOffer = require './special_offer'
Star = require './star'
Stream = require './stream'
Theme = require './theme'
Thread = require './thread'
ThreadComment = require './thread_comment'
ThreadVote = require './thread_vote'
User = require './user'
UserData = require './user_data'
UserFollower = require './user_follower'
UserItem = require './user_item'
Video = require './video'
Drawer = require './drawer'
XpGain = require './xp_gain'
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

    userAgent = serverHeaders['user-agent'] or navigator?.userAgent

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

    @cookie = new Cookie {cookieSubject}
    @l = new Language {language, @cookie}

    @auth = new Auth {@exoid, cookieSubject, pushToken, @l, userAgent}
    @user = new User {@auth, proxy, @exoid, @cookie}
    @userData = new UserData {@auth}
    @userFollower = new UserFollower {@auth}
    @userItem = new UserItem {@auth}
    @player = new Player {@auth}
    @ad = new Ad {@portal, @cookie, userAgent}
    @addon = new Addon {@auth, @l}
    @ban = new Ban {@auth}
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
    @groupAuditLog = new GroupAuditLog {@auth}
    @groupUser = new GroupUser {@auth}
    @groupUserXpTransaction = new GroupUserXpTransaction {@auth}
    @groupRecord = new GroupRecord {@auth}
    @groupRecordType = new GroupRecordType {@auth}
    @groupRole = new GroupRole {@auth}
    @gameRecordType = new GameRecordType {@auth}
    @image = new Image()
    @item = new Item {@auth}
    @thread = new Thread {@auth, @l}
    @threadComment = new ThreadComment {@auth}
    @threadVote = new ThreadVote {@auth}
    @nps = new Nps {@auth}
    @payment = new Payment {@auth}
    @product = new Product {@auth}
    @pushToken = new PushToken {@auth, pushToken}
    @reward = new Reward {@auth}
    @specialOffer = new SpecialOffer {@auth}
    @star = new Star {@auth}
    @stream = new Stream {@auth}
    @theme = new Theme()
    @video = new Video {@auth}
    @drawer = new Drawer()
    @xpGain = new XpGain()
    @signInDialog = new SignInDialog()
    @getAppDialog = new GetAppDialog()
    @installOverlay = new InstallOverlay()
    @imageViewOverlay = new ImageViewOverlay()
    @pushNotificationSheet = new PushNotificationSheet()
    @portal?.setModels {
      @user, @game, @player, @clan, @clashRoyaleMatch, @clashRoyalePlayerDeck,
      @clanRecordType, @gameRecordType, @modal, @installOverlay, @getAppDialog,
      @pushToken

    }
    @window = new Window {@cookie, @experiment}

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
