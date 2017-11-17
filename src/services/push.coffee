Environment = require 'clay-environment'
# TODO separate bundle for app that doesn't require this
firebase = require 'firebase/app'
require 'firebase/messaging'

SemverService = require '../services/semver'
config = require '../config'

class PushService
  constructor: ->
    if window? and not Environment.isGameApp config.GAME_KEY
      firebase.initializeApp {
        apiKey: config.FIREBASE.API_KEY
        authDomain: config.FIREBASE.AUTH_DOMAIN
        databaseURL: config.FIREBASE.DATABASE_URL
        projectId: config.FIREBASE.PROJECT_ID
        messagingSenderId: config.FIREBASE.MESSAGING_SENDER_ID
      }
      @firebaseMessaging = firebase.messaging()
      @isReady = new Promise (@resolveReady) => null

  setFirebaseServiceWorker: (registration) =>
    @firebaseMessaging?.useServiceWorker registration
    @resolveReady?()

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
      console.log token
      if token?
        lang = model.l.getLanguageStr()
        model.portal.call 'push.subscribeToTopic', {token, topic: 'all'}
        model.portal.call 'push.subscribeToTopic', {token, topic: "#{lang}"}
        if not isAlwaysCalled or not localStorage?['isPushTokenStored']
          appVersion = Environment.getAppVersion config.GAME_KEY
          isIosFCM = appVersion and SemverService.gte(appVersion, '1.3.1')
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

  registerWeb: =>
    getToken = (isSecondAttempt) =>
      @firebaseMessaging.requestPermission()
      .then =>
        @firebaseMessaging.getToken()
      .catch (err) ->
        # if the user has an old VAPID token, getToken fails... so resub them
        navigator.serviceWorker.ready.then (serviceWorkerRegistration) ->
          serviceWorkerRegistration.pushManager.getSubscription()
          .then (subscription) ->
            subscription.unsubscribe()
          .then ->
            unless isSecondAttempt
              getToken true

    @isReady.then ->
      getToken()
    .then (token) ->
      {token, sourceType: 'web-fcm'}

  subscribeToTopic: ({model, topic, token}) =>
    if token
      tokenPromise = Promise.resolve token
    else
      tokenPromise = @firebaseMessaging.getToken()

    tokenPromise
    .then (token) ->
      model.pushToken.subscribeToTopic {topic, token}
    .catch (err) ->
      console.log 'caught', err


module.exports = new PushService()
