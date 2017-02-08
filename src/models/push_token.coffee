Environment = require 'clay-environment'

module.exports = class PushToken
  namespace: 'pushTokens'

  constructor: ({@auth, @pushToken}) -> null

  create: ({token, sourceType} = {}) =>
    unless localStorage['pushTokenStored']
      @auth.call "#{@namespace}.create", {sourceType, token}
      .then ->
        localStorage['pushTokenStored'] = '1'
      .catch (response) ->
        if response.status is '400' # push token already stored
          localStorage['pushTokenStored'] = '1'

  claimToken: (token) =>
    @auth.call "#{@namespace}.updateByToken", {token}

  setCurrentPushToken: (pushToken) =>
    @pushToken.onNext pushToken

  getCurrentPushToken: =>
    @pushToken
