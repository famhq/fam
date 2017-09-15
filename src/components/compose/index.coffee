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
    {@model, @router, @titleValue, @titleValueStreams, @bodyValue,
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
      titleValue: @titleValueStreams?.switch() or @titleValue

  setTitle: (e) =>
    if @titleValueStreams
      @titleValueStreams.onNext Rx.Observable.just e.target.value
    else
      @titleValue.onNext e.target.value

  setBody: (e) =>
    if @bodyValueStreams
      @bodyValueStreams.onNext Rx.Observable.just e.target.value
    else
      @bodyValue.onNext e.target.value

  render: ({isReply, onDone, $head}) =>
    {me, isLoading, titleValue} = @state.getValue()

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
          $head
          unless isReply
            [
              z 'input.title',
                type: 'text'
                onkeyup: @setTitle
                onchange: @setTitle
                # bug where cursor goes to end w/ just value
                defaultValue: titleValue
                placeholder: @model.l.get 'compose.titleHintText'

              z '.divider'
            ]
          z @$markdownEditor,
            hintText: if isReply \
                      then @model.l.get 'compose.responseHintText'
                      else @model.l.get 'compose.postHintText'
        ]
