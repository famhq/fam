z = require 'zorium'
log = require 'loga'
Rx = require 'rx-lite'

Icon = require '../icon'
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class Compose
  constructor: ({@model, @router, @titleValue, @bodyValue}) ->
    me = @model.user.getMe()

    @$discardIcon = new Icon()
    @$doneIcon = new Icon()

    @state = z.state
      me: me
      isLoading: false

  setTitle: (e) =>
    @titleValue.onNext e.target.value

  setBody: (e) =>
    @bodyValue.onNext e.target.value

  render: ({isReply, onDone}) =>
    {me, isLoading} = @state.getValue()

    z '.z-compose',
      z '.actions',
        z '.action', {
          onclick: =>
            @router.back()
        },
          z '.icon',
            z @$discardIcon,
              icon: 'close'
              color: colors.$primary500
              isTouchTarget: false
          z '.text', 'Discard'
        z '.action', {
          onclick: (e) =>
            @state.set isLoading: true
            onDone e
            .then =>
              @state.set isLoading: false
        },
          z '.icon',
            z @$doneIcon,
              icon: 'check'
              color: colors.$primary500
              isTouchTarget: false
          z '.text',
            if isLoading then 'Loading...' else 'Done'
      z '.g-grid',
        [
          unless isReply
            [
              z 'input.title',
                type: 'text'
                onkeyup: @setTitle
                onchange: @setTitle
                placeholder: 'Title...'

              z '.divider'
            ]
          z 'textarea.textarea',
            # for some reason necessary on iOS to get it to focus properly
            onclick: (e) ->
              setTimeout ->
                e?.target?.focus()
              , 0
            placeholder: if isReply \
                        then 'Write a response'
                        else 'Write a post...'
            onkeyup: @setBody
            onchange: @setBody
        ]
