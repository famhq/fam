Environment = require '../services/environment'

module.exports = class PushToken
  namespace: 'pushTokens'

  constructor: ({@auth, @pushToken}) -> null

  create: ({token, sourceType, language, deviceId} = {}) =>
    @auth.call "#{@namespace}.create", {token, sourceType, language, deviceId}

  claimToken: (token) =>
    @auth.call "#{@namespace}.updateByToken", {token}

  setCurrentPushToken: (pushToken) =>
    @pushToken.next pushToken

  getCurrentPushToken: =>
    @pushToken
