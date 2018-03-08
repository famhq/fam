_map = require 'lodash/map'
Environment = require '../services/environment'
Fingerprint = require 'fingerprintjs'
getUuidByString = require 'uuid-by-string'

PushService = require '../services/push'
config = require '../config'

if window?
  PortalGun = require 'portal-gun'

urlBase64ToUint8Array = (base64String) ->
  padding = '='.repeat((4 - (base64String.length % 4)) % 4)
  base64 = (base64String + padding).replace(/\-/g, '+').replace(/_/g, '/')
  rawData = window.atob(base64)
  outputArray = new Uint8Array(rawData.length)
  i = 0
  while i < rawData.length
    outputArray[i] = rawData.charCodeAt(i)
    i += 1
  outputArray

module.exports = class Portal
  constructor: ->
    if window?
      @portal = new PortalGun() # TODO: check isParentValid

      @appResumeHandler = null

  PLATFORMS:
    GAME_APP: 'game_app'
    CLAY_APP: 'clay_app'
    WEB: 'web'

  setModels: (props) =>
    {@user, @game, @player, @clan, @clashRoyaleMatch, @clashRoyalePlayerDeck,
      @gameRecordType, @clanRecordType, @pushToken,
      @modal, @installOverlay, @getAppDialog} = props
    null

  call: (args...) =>
    unless window?
      # throw new Error 'Portal called server-side'
      return console.log 'Portal called server-side'

    @portal.call args...
    .catch ->
      # if we don't catch, zorium freaks out if a portal call is in state
      # (infinite errors on page load/route)
      console.log 'missing portal call', args
      null

  callWithError: (args...) =>
    unless window?
      # throw new Error 'Portal called server-side'
      return console.log 'Portal called server-side'

    @portal.call args...

  listen: =>
    unless window?
      throw new Error 'Portal called server-side'

    @portal.listen()

    @portal.on 'auth.getStatus', @authGetStatus
    @portal.on 'share.any', @shareAny
    @portal.on 'env.getPlatform', @getPlatform
    @portal.on 'app.install', @appInstall
    @portal.on 'app.rate', @appRate
    @portal.on 'app.getDeviceId', @appGetDeviceId

    # fallbacks
    @portal.on 'app.onResume', @appOnResume

    @portal.on 'top.onData', -> null
    @portal.on 'top.getData', -> null
    @portal.on 'push.register', @pushRegister

    @portal.on 'twitter.share', @twitterShare

    @portal.on 'networkInformation.onOffline', @networkInformationOnOffline
    @portal.on 'networkInformation.onOnline', @networkInformationOnOnline

    # SDK
    @portal.on 'clashRoyale.player.getMe', @clashRoyalePlayerGetMe
    @portal.on 'clashRoyale.player.getByTag', @clashRoyalePlayerGetByTag
    @portal.on 'clashRoyale.clan.getByTag', @clashRoyaleClanGetByTag
    @portal.on 'clashRoyale.match.getAllByTag', @clashRoyaleMatchGetAllByTag
    @portal.on 'clashRoyale.deck.getAllByTag', @clashRoyaleDeckGetAllByTag
    @portal.on(
      'clashRoyale.user.getAllByPlayerTag'
      @clashRoyaleUserGetAllByPlayerTag
    )
    @portal.on(
      'clashRoyale.userRecord.getAllByTag'
      @clashRoyaleUserRecordGetAllByTag
    )
    @portal.on(
      'clashRoyale.clanRecord.getAllByTag'
      @clashRoyaleClanRecordGetAllByTag
    )
    @portal.on 'forum.share', @forumShare

    @portal.on 'browser.openWindow', ({url, target, options}) ->
      window.open url, target, options


  ###
  @typedef AuthStatus
  @property {String} accessToken
  @property {String} userId
  ###

  ###
  @returns {Promise<AuthStatus>}
  ###
  authGetStatus: =>
    @model.user.getMe()
    .take(1).toPromise()
    .then (user) ->
      accessToken: user.id # Temporary
      userId: user.id

  shareAny: ({text, imageUrl, path}) =>
    ga? 'send', 'event', 'share_service', 'share_any'

    url = "https://#{config.HOST}#{path}"
    text = "#{text} #{url}"
    @call 'twitter.share', {text}

  getPlatform: ({gameKey} = {}) =>
    userAgent = navigator.userAgent
    switch
      when Environment.isNativeApp(gameKey, {userAgent})
        @PLATFORMS.GAME_APP
      when Environment.isClayApp({userAgent})
        @PLATFORMS.CLAY_APP
      else
        @PLATFORMS.WEB

  isChrome: ->
    navigator.userAgent.match /chrome/i

  appRate: =>
    ga? 'send', 'event', 'native', 'rate'

    @call 'browser.openWindow',
      url: if Environment.isiOS() \
           then config.ITUNES_APP_URL
           else config.GOOGLE_PLAY_APP_URL
      target: '_system'

  appGetDeviceId: ->
    getUuidByString "#{new Fingerprint().get()}"

  appOnResume: (callback) =>
    if @appResumeHandler
      window.removeEventListener 'visibilitychange', @appResumeHandler

    @appResumeHandler = ->
      unless document.hidden
        callback()

    window.addEventListener 'visibilitychange', @appResumeHandler

  appInstall: ({group} = {}) =>
    iosAppId = group?.iosAppId or config.DEFAULT_IOS_APP_ID
    googlePlayAppId = group?.googlePlayAppId or
                        config.DEFAULT_GOOGLE_PLAY_APP_ID

    iosAppUrl = 'https://itunes.apple.com/us/app/fam/id' + iosAppId
    googlePlayAppUrl = 'https://play.google.com/store/apps/details?id=' +
      googlePlayAppId

    if Environment.isAndroid() and @isChrome()
      if @installOverlay.prompt
        prompt = @installOverlay.prompt
        @installOverlay.setPrompt null
      else
        @installOverlay.open()

    else if Environment.isiOS()
      @call 'browser.openWindow',
        url: iosAppUrl
        target: '_system'

    else if Environment.isAndroid()
      @call 'browser.openWindow',
        url: googlePlayAppUrl
        target: '_system'

    else
      @getAppDialog.open()

  twitterShare: ({text}) =>
    @call 'browser.openWindow', {
      url: "https://twitter.com/intent/tweet?text=#{encodeURIComponent text}"
      target: '_system'
    }

  facebookShare: ({url}) ->
    FB.ui {
      method: 'share',
      href: url
    }

  clashRoyalePlayerGetMe: ({refreshIfStale, appId} = {}) =>
    if appId
      ga? 'send', 'event', 'sdk', appId, 'clashRoyalePlayerGetMe'

    @user.getMe()
    .switchMap (me) =>
      @player.getByUserIdAndGameKey me?.id, 'clash-royale', {
        refreshIfStale
      }
      .map (player) -> player.data
    .take(1).toPromise()

  clashRoyalePlayerGetByTag: ({tag, refreshIfStale, appId}) =>
    if appId
      ga? 'send', 'event', 'sdk', appId, 'clashRoyalePlayerGetByTag'

    @player.getByPlayerIdAndGameKey tag, 'clash-royale', {
      refreshIfStale
    }
    .map (player) ->
      unless player
        throw {statusCode: 404, info: 'player not found'}
      player.data
    .take(1).toPromise()

  clashRoyaleClanGetByTag: ({tag, refreshIfStale, appId}) =>
    if appId
      ga? 'send', 'event', 'sdk', appId, 'clashRoyaleClanGetByTag'

    @clan.getByClanIdAndGameKey tag, 'clash-royale', {refreshIfStale}
    .map (clan) ->
      unless clan
        throw {statusCode: 404, info: 'clan not found'}
      clan.data
    .take(1).toPromise()

  clashRoyaleUserGetAllByPlayerTag: ({playerTag, appId}) =>
    if appId
      ga? 'send', 'event', 'sdk', appId, 'clashRoyaleUserGetAllByPlayerTag'

    @user.getAllByPlayerIdAndGameKey playerTag, 'clash-royale'
    .take(1).toPromise()

  clashRoyaleMatchGetAllByTag: ({tag, limit, cursor, appId}) =>
    if appId
      ga? 'send', 'event', 'sdk', appId, 'clashRoyaleMatchGetAllByTag'

    @clashRoyaleMatch.getAllByPlayerId tag, {
      limit, cursor
    }
    .take(1).toPromise()
    .then ({results, cursor}) ->
      {
        results: _map results, 'data'
        cursor
      }

  clashRoyaleDeckGetAllByTag: ({tag, appId}) =>
    if appId
      ga? 'send', 'event', 'sdk', appId, 'clashRoyaleDeckGetAllByTag'

    @clashRoyalePlayerDeck.getAllByPlayerId tag, 'clash-royale'
    .take(1).toPromise()

  clashRoyaleUserRecordGetAllByTag: ({tag, appId}) =>
    if appId
      ga? 'send', 'event', 'sdk', appId, 'clashRoyaleUserRecordGetAllByTag'

    @gameRecordType.getAllByPlayerIdAndGameKey tag, 'clash-royale', {
      embed: ['meValues']
    }
    .take(1).toPromise()

  clashRoyaleClanRecordGetAllByTag: ({tag, appId}) =>
    if appId
      ga? 'send', 'event', 'sdk', appId, 'clashRoyaleClanRecordGetAllByTag'

    @clanRecordType.getAllByClanIdAndGameKey tag, 'clash-royale', {
      embed: ['clanValues']
    }
    .take(1).toPromise()

  forumShare: ->
    console.log 'TODO'

  pushRegister: ->
    PushService.registerWeb()
    # navigator.serviceWorker.ready.then (serviceWorkerRegistration) =>
    #   serviceWorkerRegistration.pushManager.subscribe {
    #     userVisibleOnly: true,
    #     applicationServerKey: urlBase64ToUint8Array config.VAPID_PUBLIC_KEY
    #   }
    #   .then (subscription) ->
    #     subscriptionToken = JSON.stringify subscription
    #     {token: subscriptionToken, sourceType: 'web'}
    #   .catch (err) =>
    #     serviceWorkerRegistration.pushManager.getSubscription()
    #     .then (subscription) ->
    #       subscription.unsubscribe()
    #     .then =>
    #       unless isSecondAttempt
    #         @pushRegister true
    #     .catch (err) ->
    #       console.log err

  networkInformationOnOnline: (fn) ->
    window.addEventListener 'online', fn

  networkInformationOnOffline: (fn) ->
    window.addEventListener 'offline', fn
