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

      @appResumeHandler = null

  PLATFORMS:
    GAME_APP: 'game_app'
    CLAY_APP: 'clay_app'
    WEB: 'web'

  setModels: ({@user, @game, @modal, @installOverlay, @getAppDialog}) => null

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
    @portal.on 'app.rate', @appRate

    # fallbacks
    @portal.on 'app.onResume', @appOnResume

    @portal.on 'top.onData', -> null
    @portal.on 'top.getData', -> null
    @portal.on 'push.register', @pushRegister

    @portal.on 'twitter.share', @twitterShare

    @portal.on 'facebook.login', @facebookLogin
    @portal.on 'facebook.share', @facebookShare

    @portal.on 'networkInformation.onOffline', @networkInformationOnOffline
    @portal.on 'networkInformation.onOnline', @networkInformationOnOnline

    # SDK
    @portal.on 'player.getMe', @playerGetMe
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
      when Environment.isGameApp(gameKey, {userAgent})
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

  appOnResume: (callback) =>
    if @appResumeHandler
      window.removeEventListener 'visibilitychange', @appResumeHandler

    @appResumeHandler = ->
      unless document.hidden
        callback()

    window.addEventListener 'visibilitychange', @appResumeHandler

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

    else if Environment.isAndroid()
      @call 'browser.openWindow',
        url: config.GOOGLE_PLAY_APP_URL
        target: '_system'

    else
      @getAppDialog.open()

  twitterShare: ({text}) =>
    @call 'browser.openWindow', {
      url: "https://twitter.com/intent/tweet?text=#{encodeURIComponent text}"
      target: '_system'
    }

  facebookLogin: ->
    new Promise (resolve) ->
      FB.getLoginStatus (response) ->
        if response.status is 'connected'
          resolve {
            status: response.status
            facebookAccessToken: response.authResponse.accessToken
            id: response.authResponse.userID
          }
        else if Environment.isGameChromeApp(config.GAME_KEY)
          redirectUri = encodeURIComponent(
            "https://#{config.HOST}/facebook-login/chrome"
          )
          window.location.href = 'https://www.facebook.com/dialog/oauth?' +
               "client_id=#{config.FB_ID}&" +
               "redirect_uri=#{redirectUri}&" +
               'response_type=token'
        else
          FB.login (response) ->
            resolve {
              status: response.status
              facebookAccessToken: response.authResponse.accessToken
              id: response.authResponse.userID
            }

  facebookShare: ({url}) ->
    FB.ui {
      method: 'share',
      href: url
    }

  playerGetMe: =>
    @user.getMe().take(1).toPromise()

  forumShare: =>
    console.log 'TODO'

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
