Rx = require 'rx-lite'
Environment = require 'clay-environment'

config = require '../config'

module.exports = class PushToken
  constructor: ({@auth, @pushToken}) ->

  create: ({token} = {}) =>
    unless localStorage['pushTokenStored']
      sourceType = if Environment.isAndroid() then 'android' else 'ios'
      @auth.call 'pushTokens.create', {sourceType, token}
      .then ->
        localStorage['pushTokenStored'] = '1'
      .catch (response) ->
        if response.status is '400' # push token already stored
          localStorage['pushTokenStored'] = '1'

  claimToken: (token) =>
    @auth.call 'pushTokens.updateByToken', {token}

  setCurrentPushToken: (pushToken) =>
    @pushToken.onNext pushToken

  getCurrentPushToken: =>
    @pushToken
