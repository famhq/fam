module.exports = class Ad
  constructor: ({@portal}) -> null

  hideAds: (timeMs) =>
    # not super secure, but works for now
    localStorage?['hideAdsUntil'] = Date.now() + timeMs
    @portal.call 'admob.hideBanner'

  isVisible: ->
    not localStorage?['hideAdsUntil'] or
      Date.now() > parseInt(localStorage?['hideAdsUntil'])
