_ = require 'lodash'
Rx = require 'rx-lite'
Environment = require 'clay-environment'

config = require '../config'

if window?
  kik = require 'kik'
  PortalGun = require 'portal-gun'

module.exports = class Portal
  constructor: ({@user, @game, @modal}) ->
    if window?
      @portal = new PortalGun() # TODO: check isParentValid

  PLATFORMS:
    KIK: 'kik'
    GAME_APP: 'game_app'
    CLAY_APP: 'clay_app'
    WEB: 'web'

  call: (args...) =>
    unless window?
      throw new Error 'Portal called server-side'

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

    @portal.on 'auth.kikLogin', @kikLogin
    @portal.on 'auth.getStatus', @authGetStatus
    @portal.on 'share.any', @shareAny
    @portal.on 'env.getPlatform', @getPlatform

    @portal.on 'bot.open', @botOpen

    @portal.on 'top.getData', -> kik.message

    @portal.on 'messenger.isInstalled', -> false

    @portal.on 'kik.isEnabled', -> kik.enabled

    @portal.on 'browser.openWindow', ({url, target, options}) =>
      if kik?.enabled and options?.allowKik
        @call 'kik.open', url, true
      else
        window.open url, target, options

    if kik.enabled
      @portal.on 'kik.bot.linkUser', (username, data) ->
        new Promise (resolve, reject) ->
          kik.bot.linkUser username, data, (err, username) ->
            if err? then reject err else resolve username
      @portal.on 'kik.sign', (data) ->
        new Promise (resolve) ->
          kik.sign data, (signedData, username, host) ->
            if signedData?
              resolve {signedData, username, host}
            else
              resolve null
      @portal.on 'kik.open', -> kik.open.apply null, arguments
      @portal.on 'kik.openConversation', ->
        kik.openConversation.apply null, arguments
      @portal.on 'kik.getMessage', -> kik.message
      @portal.on 'kik.send', -> kik.send.apply null, arguments
      @portal.on 'kik.browser.setOrientationLock', ->
        kik.browser.setOrientationLock.apply null, arguments
      @portal.on 'kik.metrics.enableGoogleAnalytics', ->
        kik.metrics.enableGoogleAnalytics.apply null, arguments
      @portal.on 'kik.getAnonymousUser', ->
        new Promise (resolve) ->
          kik.getAnonymousUser resolve
      @portal.on 'kik.getUser', ->
        new Promise (resolve) ->
          kik.getUser resolve
      @portal.on 'kik.photo.get', ->
        new Promise (resolve) ->
          kik.photo.get arguments[0], resolve


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

  botOpen: ({platform} = {}) =>
    currentPlatform = Environment.getPlatform {gameKey: config.GAME_KEY}
    if platform is 'kik' and currentPlatform is 'kik'
      @call 'kik.openConversation', config.KIK_USERNAME
    else if platform is 'kik'
      @call 'browser.openWindow', {
        url: "kik://user/#{config.KIK_USERNAME}/profile"
        target: '_system'
      }
    else if platform is 'messenger' and Environment.isAndroid()
      @call 'browser.openWindow', {
        url: "intent://user/#{config.FB_PAGE_ID}/" +
             '#Intent;scheme=fb-messenger;package=com.facebook.orca;end'
        target: '_system'
      }
    else if platform is 'discord'
      @call 'browser.openWindow', {
        url: "https://discordapp.com/channels/@me/#{config.DISCORD_ID}"
        target: '_system'
      }

  kikLogin: =>
    userAgent = window.navigator.userAgent

    @call 'kik.getUser'
    .then (user) =>
      unless user?
        return null
      @call 'kik.sign', user.username
      .then ({signedData, username, host} = {}) ->
        unless signedData?
          return null
        {signedData, kikUsername: user.username}

  getPlatform: ({gameKey} = {}) =>
    userAgent = navigator.userAgent

    @call 'kik.isEnabled'
    .then (isKikEnabled) =>
      switch
        when isKikEnabled
          @PLATFORMS.KIK
        when Environment.isGameApp(gameKey, {userAgent})
          @PLATFORMS.GAME_APP
        when Environment.isClayApp({userAgent})
          @PLATFORMS.CLAY_APP
        else
          @PLATFORMS.WEB
