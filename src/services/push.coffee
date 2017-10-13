Environment = require 'clay-environment'
semver = require 'semver'

config = require '../config'

class PushService
  init: ({model}) ->
    onReply = ([reply]) ->
      payload = reply.additionalData.payload or reply.additionalData.data
      model.chatMessage.create {
        body: reply.additionalData.inlineReply
        conversationId: payload.conversationId
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
          appVersion = Environment.getAppVersion config.GAME_KEY
          isIosFCM = appVersion and semver.gte(appVersion, '1.3.1')
          sourceType ?= if Environment.isAndroid() \
                        then 'android'
                        else if isIosFCM
                        then 'ios-fcm'
                        else 'ios'
          model.pushToken.create {token, sourceType}
          localStorage?['isPushTokenStored'] = 1
        model.pushToken.setCurrentPushToken token
    .catch (err) ->
      unless err.message is 'Method not found'
        console.log err


module.exports = new PushService()
