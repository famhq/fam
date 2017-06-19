z = require 'zorium'
Rx = require 'rx-lite'

Compose = require '../compose'

if window?
  require './index.styl'

module.exports = class NewThread
  constructor: ({@model, @router}) ->
    @titleValue ?= new Rx.BehaviorSubject ''
    @bodyValueStreams ?= new Rx.ReplaySubject 1
    @bodyValueStreams.onNext new Rx.BehaviorSubject ''
    @attachmentsValueStreams ?= new Rx.ReplaySubject 1
    @attachmentsValueStreams.onNext new Rx.BehaviorSubject []

    @$compose = new Compose {
      @model, @router, @titleValue, @bodyValueStreams, @attachmentsValueStreams
    }

    @state = z.state
      me: @model.user.getMe()
      bodyValue: @bodyValueStreams.switch()
      attachmentsValue: @attachmentsValueStreams.switch()

  render: =>
    {me, bodyValue, attachmentsValue} = @state.getValue()

    z '.z-new-thread',
      z @$compose,
        onDone: (e) =>
          @model.signInDialog.openIfGuest me
          .then =>
            @model.thread.create {
              title: @titleValue.getValue()
              body: bodyValue
              attachments: attachmentsValue
            }
          .then ({id}) =>
            @bodyValueStreams.onNext Rx.Observable.just null
            @attachmentsValueStreams.onNext Rx.Observable.just null
            @router.go "/thread/#{id}", {reset: true}
