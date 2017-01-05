z = require 'zorium'
_map = require 'lodash/map'
Rx = require 'rx-lite'

Icon = require '../icon'
UploadOverlay = require '../upload_overlay'
ConversationImagePreview = require '../conversation_image_preview'
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

DEFAULT_TEXTAREA_HEIGHT = 54

module.exports = class ConversationTextarea
  constructor: (options) ->
    {@model, @message, @onPost, @onFocus,
      @isTextareaFocused, @overlay$} = options

    @imageData = new Rx.BehaviorSubject null

    @$conversationImagePreview = new ConversationImagePreview {
      @imageData
      @overlay$
      @model
      onUpload: ({key}) =>
        @setMessage "![](local://#{key})"
        @postMessage()
    }
    @$sendIcon = new Icon()

    @panels = [
      {
        $icon: new Icon()
        icon: 'text'
        panel: 'text'
      }
      {
        $icon: new Icon()
        icon: 'stickers'
        panel: 'stickers'
      }
      {
        $icon: new Icon()
        icon: 'image'
        onclick: -> null
        $uploadOverlay: new UploadOverlay {@model}
      }
    ]

    @isTextareaFocused ?= new Rx.BehaviorSubject false

    @state = z.state
      currentPanel: 'text'
      isTextareaFocused: @isTextareaFocused
      imageFile: null
      imageDataUrl: null
      imageWidth: null
      imageHeight: null
      hasText: false

  afterMount: (@$$el) =>
    null

  setMessageFromEvent: (e) =>
    e or= window.event
    if e.keyCode is 13 and not e.shiftKey
      e.preventDefault()
      @postMessage()
    else
      @setMessage e.target.value

  setMessage: (message) =>
    currentValue = @message.getValue()
    if not currentValue and message
      @state.set hasText: true
    else if currentValue and not message
      @state.set hasText: false
    @message.onNext message

  postMessage: (e) =>
    $$textarea = @$$el.querySelector('#textarea')
    $$textarea?.focus()
    $$textarea?.style.height = 'auto'
    @onPost?()
    # hack: don't want to keep textarea value in state, too slow
    # to re-render on every letter typed
    @$$el.querySelector('.textarea').value = ''
    @setMessage ''

  resizeTextarea: (e) ->
    $$textarea = e.target
    $$textarea.style.height = "#{DEFAULT_TEXTAREA_HEIGHT}px"
    $$textarea.style.height = $$textarea.scrollHeight + 'px'
    $$textarea.scrollTop = $$textarea.scrollHeight

  render: ({color, onclick} = {}) =>
    {currentPanel, isTextareaFocused, hasText} = @state.getValue()

    z '.z-conversation-textarea',
      z '.g-grid',
        if currentPanel is 'stickers'
          z '.sticker-panel',
            z '.stickers',
              _map config.STICKERS, (sticker) =>
                z '.sticker',
                  onclick: (e) =>
                    @setMessage ":#{sticker}:"
                    @postMessage e
                    @state.set currentPanel: text
                  style:
                    backgroundImage:
                      "url(#{config.CDN_URL}/groups/emotes/#{sticker}.png)"
        else
          z '.text-panel',
            z 'textarea.textarea',
              id: 'textarea'
              # for some reason necessary on iOS to get it to focus properly
              onclick: (e) ->
                setTimeout ->
                  e?.target?.focus()
                , 0
              placeholder: 'Type a message'
              onkeyup: @setMessageFromEvent
              onkeydown: (e) ->
                if e.keyCode is 13 and not e.shiftKey
                  e.preventDefault()
              oninput: @resizeTextarea
              onfocus: =>
                clearTimeout @blurTimeout
                @isTextareaFocused.onNext true
                @onFocus?()
              onblur: =>
                @blurTimeout = setTimeout =>
                  @isTextareaFocused.onNext false
                , 350

            z '.right-icons',
              z '.send-icon', {
                onclick: @postMessage
              },
                z @$sendIcon,
                  icon: 'send'
                  color: if hasText \
                         then colors.$white
                         else colors.$white30

        z '.bottom-icons',
          _map @panels, ({$icon, icon, panel, onclick, $uploadOverlay}) =>
            z '.icon',
              z $icon, {
                onclick: onclick or =>
                  @state.set currentPanel: panel
                icon: icon
                color: if currentPanel is panel \
                       then colors.$white
                       else colors.$white30
                isTouchTarget: true
                touchHeight: '36px'
              }
              if $uploadOverlay
                z '.upload-overlay',
                  z $uploadOverlay, {
                    onSelect: ({file, dataUrl}) =>
                      img = new Image()
                      img.src = dataUrl
                      img.onload = =>
                        @imageData.onNext {
                          file
                          dataUrl
                          width: img.width
                          height: img.height
                        }
                        @overlay$.onNext @$conversationImagePreview
                  }
