z = require 'zorium'
Rx = require 'rxjs'
_map = require 'lodash/map'

Icon = require '../icon'
CardPickerDialog = require '../card_picker_dialog'
UploadOverlay = require '../upload_overlay'
ConversationImagePreview = require '../conversation_image_preview'
config = require '../../config'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class MarkdownEditor
  constructor: (options) ->
    {@model, @valueStreams, @attachmentsValueStreams, @value, @error} = options
    @value ?= new Rx.BehaviorSubject ''
    @error ?= new Rx.BehaviorSubject null
    @overlay$ = new Rx.BehaviorSubject null
    @imageData = new Rx.BehaviorSubject null

    @$cardPickerDialog = new CardPickerDialog {@model, @overlay$}
    @$conversationImagePreview = new ConversationImagePreview {
      @imageData
      @model
      @overlay$
      onUpload: ({smallUrl, largeUrl, key, width, height}) =>
        {attachments} = @state.getValue()

        attachments or= []
        @attachmentsValueStreams.next Rx.Observable.of(attachments.concat [
          {type: 'image', src: smallUrl, smallSrc: smallUrl, largeSrc: largeUrl}
        ])
        @setModifier {
          pattern: "![](#{largeUrl} =#{width}x#{height})"
        }
    }

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
          @overlay$.next @$cardPickerDialog
          @$cardPickerDialog.onPick (card) =>
            @setModifier {
              pattern: "[#{card.name}]" +
                        "(https://#{config.HOST}/clashRoyale/card/#{card.key})"
            }
      }
      {
        icon: 'image'
        $icon: new Icon()
        title: 'Image'
        pattern: "[$1](https://#{config.HOST}/clashRoyale/card/$0)"
        $uploadOverlay: new UploadOverlay {@model}
      }
    ]

    @state = z.state {
      value: @valueStreams?.switch() or @value
      attachments: @attachmentsValueStreams.switch()
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
      @valueStreams.next Rx.Observable.of value
    else
      @value.next value

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
      z 'textarea.textarea', {
        placeholder: hintText or ''
        onkeyup: @setValueFromEvent
        # bug where cursor goes to end w/ just value
        defaultValue: value
      }

      z '.panel',
        _map @modifiers, (options) =>
          {icon, $icon, title, pattern, onclick, $uploadOverlay} = options
          z '.icon', {
            title: title
          },
            z $icon, {
              icon: icon
              color: colors.$white
              onclick: =>
                if onclick
                  onclick()
                else
                  @setModifier {pattern, onclick}
            }
            if $uploadOverlay
              z '.upload-overlay',
                z $uploadOverlay, {
                  onSelect: ({file, dataUrl}) =>
                    img = new Image()
                    img.src = dataUrl
                    img.onload = =>
                      @imageData.next {
                        file
                        dataUrl
                        width: img.width
                        height: img.height
                      }
                      @overlay$.next @$conversationImagePreview
                }

      overlay$
