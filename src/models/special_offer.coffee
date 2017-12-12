module.exports = class SpecialOffer
  namespace: 'specialOffer'

  constructor: ({@auth}) -> null

  getAll: (options, {ignoreCache} = {}) =>
    @auth.stream "#{@namespace}.getAll", options, {ignoreCache}

  giveReward: ({offerId, usageStats}) =>
    @auth.call "#{@namespace}.giveReward", {
      offerId, usageStats
    }
