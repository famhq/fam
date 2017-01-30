z = require 'zorium'
Rx = require 'rx-lite'
_map = require 'lodash/map'

Icon = require '../icon'
CardPickerDialog = require '../card_picker_dialog'
config = require '../../config'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class MarkdownEditor
  constructor: ({@model, @valueStreams, @value, @error} = {}) ->
    @value ?= new Rx.BehaviorSubject ''
    @error ?= new Rx.BehaviorSubject null
    @overlay$ = new Rx.BehaviorSubject null

    @$cardPickerDialog = new CardPickerDialog {@model, @overlay$}

    @modifiers = [
      {
        icon: 'bold'
        $icon: new Icon()
        title: 'Bold'
        pattern: '**$0**'
      }
      {
        icon: 'italic'
        $icon: new Icon()
        title: 'Italic'
        pattern: '*$0*'
      }
      # markdown doesn't support...
      # {
      #   icon: 'underline'
      #   $icon: new Icon()
      #   title: 'Underline'
      #   pattern: '__$0__'
      # }
      {
        icon: 'bullet-list'
        $icon: new Icon()
        title: 'List'
        pattern: '- $0'
      }
      {
        icon: 'cards'
        $icon: new Icon()
        title: 'Card'
        pattern: "[$1](https://#{config.HOST}/clashRoyale/card/$0)"
        onclick: =>
          @overlay$.onNext @$cardPickerDialog
          @$cardPickerDialog.onPick (card) =>
            @setModifier {
              pattern: "[#{card.name}]" +
                        "(https://#{config.HOST}/clashRoyale/card/#{card.key})"
            }
      }
    ]

    @state = z.state {
      value: @valueStreams?.switch() or @value
      error: @error
      overlay$: @overlay$
    }

  afterMount: ($$el) =>
    @$$textarea = $$el.querySelector('.textarea')

  setValueFromEvent: (e) =>
    e?.preventDefault()

    @setValue e.target.value

  setValue: (value, {updateDom} = {}) =>
    if @valueStreams
      @valueStreams.onNext Rx.Observable.just value
    else
      @value.onNext value

    if updateDom
      @$$textarea.value = value

  setModifier: ({pattern}) =>
    # TODO: figure out a way to have this not be in state (bunch of re-renders)
    # problem is the valueStreams / switch
    {value} = @state.getValue()

    startPos = @$$textarea.selectionStart
    endPos = @$$textarea.selectionEnd
    selectedText = value.substring startPos, endPos
    newSelectedText = pattern.replace '$0', selectedText
    newOffset = pattern.indexOf '$0'
    if newOffset is -1
      newOffset = pattern.length
    newValue = value.substring(0, startPos) + newSelectedText +
               value.substring(endPos, value.length)
    @setValue newValue, {updateDom: true}
    @$$textarea.focus()
    @$$textarea.setSelectionRange startPos + newOffset, endPos + newOffset

  render: ({hintText} = {}) =>
    {value, error, overlay$} = @state.getValue()

    z '.z-markdown-editor',
      z '.panel',
        _map @modifiers, ({icon, $icon, title, pattern, onclick}, i) =>
          z '.icon', {
            title: title
          },
            z $icon,
              icon: icon
              color: colors.$white
              onclick: =>
                if onclick
                  onclick()
                else
                  @setModifier {pattern, onclick}

      z 'textarea.textarea', {
        placeholder: hintText or ''
        onkeyup: @setValueFromEvent
        value: value
      }

      overlay$
