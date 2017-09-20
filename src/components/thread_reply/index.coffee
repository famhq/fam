z = require 'zorium'
Rx = require 'rx-lite'

Compose = require '../compose'

if window?
  require './index.styl'

module.exports = class ThreadReply
  constructor: ({@model, @router, thread}) ->
    @bodyValue = new Rx.BehaviorSubject ''

    @$compose = new Compose {@model, @router, @bodyValue}

    @state = z.state
      me: @model.user.getMe()
      thread: thread

  render: =>
    {me, thread} = @state.getValue()

    z '.z-thread-reply',
      z @$compose,
        isReply: true
        onDone: (e) =>
          @model.signInDialog.openIfGuest me
          .then =>
            @model.threadComment.create {
              body: @bodyValue.getValue()
              parentId: thread.id
              parentType: 'thread'
            }
          .then =>
            @router.go @model.thread.getPath(thread), {reset: true}
