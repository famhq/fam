z = require 'zorium'
Rx = require 'rx-lite'

Icon = require '../icon'
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

DEFAULT_TEXTAREA_HEIGHT = 54

module.exports = class ConversationInputTextarea
  constructor: (options) ->
    {@message, @onPost, @onFocus, @isTextareaFocused,
      @hasText, @model} = options

    @$sendIcon = new Icon()

    @isTextareaFocused ?= new Rx.BehaviorSubject false

    @state = z.state
      isTextareaFocused: @isTextareaFocused
      hasText: @hasText

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
      @hasText.onNext true
    else if currentValue and not message
      @hasText.onNext false
    @message.onNext message

  postMessage: (e) =>
    $$textarea = @$$el.querySelector('#textarea')
    $$textarea?.focus()
    $$textarea?.style.height = 'auto'
    @onPost?()
    $$textarea?.value = ''

  resizeTextarea: (e) ->
    $$textarea = e.target
    $$textarea.style.height = "#{DEFAULT_TEXTAREA_HEIGHT}px"
    $$textarea.style.height = $$textarea.scrollHeight + 'px'
    $$textarea.scrollTop = $$textarea.scrollHeight

  render: =>
    {isTextareaFocused, hasText} = @state.getValue()

    z '.z-conversation-input-textarea',
        z 'textarea.textarea',
          id: 'textarea'
          key: 'conversation-input-textarea'
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
          ontouchstart: =>
            @model.window.pauseResizing()
          onfocus: =>
            @model.window.pauseResizing()
            clearTimeout @blurTimeout
            @isTextareaFocused.onNext true
            @onFocus?()
          onblur: (e) =>
            @blurTimeout = setTimeout =>
              isFocused = e.target is document.activeElement
              unless isFocused
                @model.window.resumeResizing()
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
