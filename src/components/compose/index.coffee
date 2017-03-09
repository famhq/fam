z = require 'zorium'

Icon = require '../icon'
ActionBar = require '../action_bar'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class Compose
  constructor: ({@model, @router, @titleValue, @bodyValue}) ->
    me = @model.user.getMe()

    @$actionBar = new ActionBar()

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
      z @$actionBar, {
        isSaving: isLoading
        cancel:
          text: 'Discard'
          onclick: =>
            @router.back()
        save:
          text: 'Done'
          onclick: (e) =>
            @state.set isLoading: true
            onDone e
            .then =>
              @state.set isLoading: false
      }
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
              setImmediate ->
                e?.target?.focus()
            placeholder: if isReply \
                        then 'Write a response'
                        else 'Write a post...'
            onkeyup: @setBody
            onchange: @setBody
        ]
