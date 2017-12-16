Environment = require 'clay-environment'

module.exports = class PushToken
  namespace: 'pushTokens'

  constructor: ({@auth, @pushToken}) -> null

  create: ({token, sourceType, language} = {}) =>
    @auth.call "#{@namespace}.create", {token, sourceType, language}

  claimToken: (token) =>
    @auth.call "#{@namespace}.updateByToken", {token}

  subscribeToTopic: ({token, topic}) =>
    @auth.call "#{@namespace}.subscribeToTopic", {token, topic}

  setCurrentPushToken: (pushToken) =>
    @pushToken.next pushToken

  getCurrentPushToken: =>
    @pushToken
