Environment = require 'clay-environment'
base64ToArrayBuffer = require 'base64-arraybuffer'

config = require '../config'

if window?
  PortalGun = require 'portal-gun'

module.exports = class Portal
  constructor: ({@user, @game, @modal}) ->
    if window?
      @portal = new PortalGun() # TODO: check isParentValid

  PLATFORMS:
    GAME_APP: 'game_app'
    CLAY_APP: 'clay_app'
    WEB: 'web'

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

    # fallbacks
    @portal.on 'app.onResume', -> null
    @portal.on 'top.onData', -> null
    @portal.on 'push.register', ->
      console.log 'try'
      # navigator.serviceWorker.ready.then (serviceWorkerRegistration) ->
      #   console.log 'ready'
      #   # TODO: check if reg'd first
      #    # https://developers.google.com/web/fundamentals/engage-and-retain/push-notifications/permissions-subscriptions
      #   arrayBufferKey = base64ToArrayBuffer.decode config.VAPID_PUBLIC_KEY
      #   console.log arrayBufferKey
      #   serviceWorkerRegistration.pushManager.subscribe {
      #     userVisibleOnly: true,
      #     applicationServerKey: arrayBufferKey
      #   }

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

  networkInformationOnOnline: (fn) ->
    window.addEventListener 'online', fn

  networkInformationOnOffline: (fn) ->
    window.addEventListener 'offline', fn
