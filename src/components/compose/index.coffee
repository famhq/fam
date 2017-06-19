z = require 'zorium'
Rx = require 'rx-lite'

Icon = require '../icon'
ActionBar = require '../action_bar'
MarkdownEditor = require '../markdown_editor'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class Compose
  constructor: (options) ->
    {@model, @router, @titleValue, @bodyValue,
      @bodyValueStreams, @attachmentsValueStreams} = options
    me = @model.user.getMe()

    @$actionBar = new ActionBar {@model}

    @attachmentsValueStreams ?= new Rx.ReplaySubject 1
    @$markdownEditor = new MarkdownEditor {
      @model
      value: @bodyValue
      valueStreams: @bodyValueStreams
      attachmentsValueStreams: @attachmentsValueStreams
    }

    @state = z.state
      me: me
      isLoading: false
      titleValue: @titleValue

  setTitle: (e) =>
    @titleValue.onNext e.target.value

  setBody: (e) =>
    if @bodyValueStreams
      @bodyValueStreams.onNext Rx.Observable.just e.target.value
    else
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
            unless isLoading
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
                placeholder: @model.l.get 'compose.titleHintText'

              z '.divider'
            ]
          z @$markdownEditor,
            hintText: if isReply \
                      then @model.l.get 'compose.responseHintText'
                      else @model.l.get 'compose.postHintText'
        ]
