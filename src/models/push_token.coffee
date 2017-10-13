Environment = require 'clay-environment'

module.exports = class PushToken
  namespace: 'pushTokens'

  constructor: ({@auth, @pushToken}) -> null

  create: ({token, sourceType} = {}) =>
    @auth.call "#{@namespace}.create", {sourceType, token}

  claimToken: (token) =>
    @auth.call "#{@namespace}.updateByToken", {token}

  setCurrentPushToken: (pushToken) =>
    @pushToken.next pushToken

  getCurrentPushToken: =>
    @pushToken
