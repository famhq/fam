Environment = require 'clay-environment'

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

  PLATFORMS:
    GAME_APP: 'game_app'
    CLAY_APP: 'clay_app'
    WEB: 'web'

  setModels: ({@user, @game, @modal, @installOverlay}) => null

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

  listen: =>
    unless window?
      throw new Error 'Portal called server-side'

    @portal.listen()

    @portal.on 'auth.getStatus', @authGetStatus
    @portal.on 'share.any', @shareAny
    @portal.on 'env.getPlatform', @getPlatform
    @portal.on 'app.install', @appInstall

    # fallbacks
    @portal.on 'app.onResume', -> null
    @portal.on 'top.onData', -> null
    @portal.on 'top.getData', -> null
    @portal.on 'push.register', @pushRegister

    @portal.on 'messenger.isInstalled', -> false

    @portal.on 'networkInformation.onOffline', @networkInformationOnOffline
    @portal.on 'networkInformation.onOnline', @networkInformationOnOnline

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
  authGetStatus: ->
    User.getMe()
    .take(1).toPromise()
    .then (user) ->
      accessToken: user.id # Temporary
      userId: user.id

  shareAny: ({title, text, dataUrl, imageUrl, path}) =>
    ga? 'send', 'event', 'share_service', 'share_any'

    url = "https://#{config.HOST}#{path}"
    title ?= ''
    text = encodeURIComponent text + ' ' + url
    @call 'browser.openWindow', {
      url: "https://twitter.com/intent/tweet?text=#{text}"
      target: '_system'
    }

  getPlatform: ({gameKey} = {}) =>
    userAgent = navigator.userAgent
    switch
      when Environment.isGameApp(gameKey, {userAgent})
        @PLATFORMS.GAME_APP
      when Environment.isClayApp({userAgent})
        @PLATFORMS.CLAY_APP
      else
        @PLATFORMS.WEB

  isChrome: ->
    navigator.userAgent.match /chrome/i

  appInstall: =>
    userAgent = navigator.userAgent
    if Environment.isGameApp(config.GAME_KEY, {userAgent})
      return null
    else if Environment.isAndroid() and @isChrome()
      if @installOverlay.prompt
        prompt = @installOverlay.prompt
        @installOverlay.setPrompt null
      else
        @installOverlay.open()

    else if Environment.isiOS()
      @call 'browser.openWindow',
        url: config.IOS_APP_URL
        target: '_system'

    else
      @call 'browser.openWindow',
        url: config.GOOGLE_PLAY_APP_URL
        target: '_system'

  pushRegister: ->
    navigator.serviceWorker.ready.then (serviceWorkerRegistration) ->
      # TODO: check if reg'd first
      # https://developers.google.com/web/fundamentals/engage-and-retain/push-notifications/permissions-subscriptions

      serviceWorkerRegistration.pushManager.subscribe {
        userVisibleOnly: true,
        applicationServerKey: urlBase64ToUint8Array config.VAPID_PUBLIC_KEY
      }
      .then (subscription) ->
        subscriptionToken = JSON.stringify subscription
        {token: subscriptionToken, sourceType: 'web'}

  pushSetContextId: ({contextId}) ->
    PushService.setContextId contextId


  networkInformationOnOnline: (fn) ->
    window.addEventListener 'online', fn

  networkInformationOnOffline: (fn) ->
    window.addEventListener 'offline', fn
