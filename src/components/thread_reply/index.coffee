_ = require 'lodash'
z = require 'zorium'
log = require 'loga'
Rx = require 'rx-lite'

Compose = require '../compose'
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class ThreadReply
  constructor: ({@model, @router, threadId}) ->
    @bodyValue = new Rx.BehaviorSubject ''

    @$compose = new Compose {@model, @router, @bodyValue}

    @state = z.state
      me: @model.user.getMe()
      threadId: threadId

  render: =>
    {me, threadId} = @state.getValue()

    z '.z-thread-reply',
      z @$compose,
        isReply: true
        onDone: (e) =>
          @model.threadMessage.create {
            body: @bodyValue.getValue()
            threadId: threadId
          }
          .then =>
            @router.go "/thread/#{threadId}/1", {reset: true}
