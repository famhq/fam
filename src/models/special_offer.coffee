module.exports = class SpecialOffer
  namespace: 'specialOffer'

  constructor: ({@auth}) -> null

  getAll: (options, {ignoreCache} = {}) =>
    @auth.stream "#{@namespace}.getAll", options, {ignoreCache}

  giveInstallReward: ({offer, deviceId, usageStats}) =>
    @auth.call "#{@namespace}.giveInstallReward", {
      offer, deviceId, usageStats
    }, {invalidateAll: true}

  giveDailyReward: ({offer, deviceId, usageStats}) =>
    @auth.call "#{@namespace}.giveDailyReward", {
      offer, deviceId, usageStats
    }, {invalidateAll: true}

  logClickById: (id, {deviceId, country}) =>
    @auth.call "#{@namespace}.logClickById", {
      id, deviceId, country
    }
