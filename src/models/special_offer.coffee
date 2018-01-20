Environment = require 'clay-environment'

config = require '../config'

module.exports = class SpecialOffer
  namespace: 'specialOffer'

  constructor: ({@auth}) -> null

  getAll: ({deviceId, language, limit}, {ignoreCache} = {}) =>
    matches = /(Android|iPhone OS) ([0-9\._]+)/g.exec(navigator.userAgent)
    osVersion = matches?[2].replace /_/g, '.'
    options = {
      deviceId: deviceId
      language: language
      screenDensity: window.devicePixelRatio
      screenResolution: "#{window.innerWidth}x#{window.innerHeight}"
      locale: navigator.languages?[0] or navigator.language or language
      osName: if Environment.isiOS() \
              then 'iOS'
              else if Environment.isAndroid()
              then 'Android'
              else 'Windows' # TODO
      osVersion: osVersion
      isApp: Environment.isGameApp config.GAME_KEY
      appVersion: Environment.getAppVersion config.GAME_KEY
      limit: limit
    }
    @auth.stream "#{@namespace}.getAll", options, {ignoreCache}

  giveInstallReward: ({offer, deviceId, usageStats}) =>
    @auth.call "#{@namespace}.giveInstallReward", {
      offer, deviceId, usageStats
    }, {invalidateAll: true}

  giveDailyReward: ({offer, deviceId, usageStats}) =>
    @auth.call "#{@namespace}.giveDailyReward", {
      offer, deviceId, usageStats
    }, {invalidateAll: true}

  logClickById: (id, {deviceId}) =>
    @auth.call "#{@namespace}.logClickById", {
      id, deviceId
    }
