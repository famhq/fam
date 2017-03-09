Environment = require 'clay-environment'

config = require '../config'

class PushService
  init: ({model}) ->
    model.portal.call 'push.registerAction', {
      action: 'reply'
    }, (reply) ->
      model.chatMessage.create {
        body: reply.additionalData.inlineReply
        conversationId: reply.additionalData.data.conversationId
      }

  register: ({model, isAlwaysCalled}) ->
    model.portal.call 'push.register'
    .then ({token, sourceType} = {}) ->
      if token?
        if not isAlwaysCalled or localStorage?['isPushTokenStored']
          sourceType ?= if Environment.isAndroid() then 'android' else 'ios'
          model.pushToken.create {token, sourceType}
          localStorage?['isPushTokenStored'] = 1
        model.pushToken.setCurrentPushToken token
    .catch (err) ->
      unless err.message is 'Method not found'
        log.error err


module.exports = new PushService()
