module.exports = class Reward
  namespace: 'rewards'

  constructor: ({@auth}) -> null

  setup: ({}) =>
    @auth.call "#{@namespace}.setup", {}

  getAll: (options, {ignoreCache} = {}) =>
    @auth.stream "#{@namespace}.getAll", options, {ignoreCache}

  incrementAttemptsByNetworkAndOfferId: ({network, offerId}) =>
    @auth.call "#{@namespace}.incrementAttemptsByNetworkAndOfferId", {
      network, offerId
    }

  videoReward: ({timestamp, successKey}) =>
    @auth.call "#{@namespace}.videoReward", {timestamp, successKey}, {
      invalidateAll: true
    }
