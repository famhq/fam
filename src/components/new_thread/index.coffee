z = require 'zorium'
Rx = require 'rx-lite'

Compose = require '../compose'

if window?
  require './index.styl'

module.exports = class NewThread
  constructor: ({@model, @router}) ->
    @titleValue ?= new Rx.BehaviorSubject ''
    @bodyValue ?= new Rx.BehaviorSubject ''

    @$compose = new Compose {@model, @router, @titleValue, @bodyValue}

    @state = z.state
      me: @model.user.getMe()

  render: =>
    {me} = @state.getValue()

    z '.z-new-thread',
      z @$compose,
        onDone: (e) =>
          @model.thread.create {
            title: @titleValue.getValue()
            body: @bodyValue.getValue()
          }
          .then ({id}) =>
            @router.go "/thread/#{id}", {reset: true}
