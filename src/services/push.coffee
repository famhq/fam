Environment = require 'clay-environment'

config = require '../config'

class PushService
  init: ({model}) ->
    onReply = (reply) ->
      model.chatMessage.create {
        body: reply.additionalData.inlineReply
        conversationId: reply.additionalData.data.conversationId
      }
    model.portal.call 'push.registerAction', {
      action: 'reply'
    }, onReply

  register: ({model, isAlwaysCalled}) ->
    model.portal.call 'push.register'
    .then ({token, sourceType} = {}) ->
      if token?
        lang = model.l.getLanguageStr()
        model.portal.call 'push.subscribeToTopic', {topic: 'all'}
        model.portal.call 'push.subscribeToTopic', {topic: lang}
        if not isAlwaysCalled or not localStorage?['isPushTokenStored']
          sourceType ?= if Environment.isAndroid() then 'android' else 'ios'
          model.pushToken.create {token, sourceType}
          localStorage?['isPushTokenStored'] = 1
        model.pushToken.setCurrentPushToken token
    .catch (err) ->
      unless err.message is 'Method not found'
        log.error err


module.exports = new PushService()
