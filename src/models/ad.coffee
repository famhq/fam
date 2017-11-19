Environment = require 'clay-environment'

CookieService = require '../services/cookie'
config = require '../config'

module.exports = class Ad
  constructor: ({@portal, @cookieSubject, @userAgent}) -> null

  hideAds: (timeMs) =>
    # not super secure, but works for now
    CookieService.set(
      @cookieSubject, 'hideAdsUntil', Date.now() + timeMs
    )
    @portal.call 'admob.hideBanner'

  isVisible: ({isWebOnly} = {}) =>
    hideAdsUntil = CookieService.get @cookieSubject, 'hideAdsUntil'
    isNativeApp = Environment.isGameApp(config.GAME_KEY, {@userAgent})
    isVisible = not hideAdsUntil or Date.now() > parseInt(hideAdsUntil)

    # TODO: rm after 11/20/17
    oldIsVisible = not localStorage?['hideAdsUntil'] or
      Date.now() > parseInt(localStorage?['hideAdsUntil'])

    (not isWebOnly or not isNativeApp) and isVisible and oldIsVisible
