z = require 'zorium'
Environment = require 'clay-environment'
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject

Icon = require '../icon'
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

DEFAULT_TEXTAREA_HEIGHT = 54

module.exports = class ConversationInputTextarea
  constructor: (options) ->
    {@message, @onPost, @onResize, @isTextareaFocused, @toggleIScroll
      @hasText, @model, isPostLoading} = options

    @$sendIcon = new Icon()

    @isTextareaFocused ?= new RxBehaviorSubject false

    @state = z.state
      isTextareaFocused: @isTextareaFocused
      isPostLoading: isPostLoading
      textareaHeight: DEFAULT_TEXTAREA_HEIGHT
      hasText: @hasText

  afterMount: (@$$el) =>
    null

  setMessageFromEvent: (e) =>
    e or= window.event
    @setMessage e.target.value

  setMessage: (message) =>
    currentValue = @message.getValue()
    if not currentValue and message
      @hasText.next true
    else if currentValue and not message
      @hasText.next false
    @message.next message

  postMessage: (e) =>
    {isPostLoading} = @state.getValue()
    unless isPostLoading
      $$textarea = @$$el.querySelector('#textarea')
      $$textarea?.focus()
      $$textarea?.style.height = "#{DEFAULT_TEXTAREA_HEIGHT}px"
      @state.set textareaHeight: DEFAULT_TEXTAREA_HEIGHT
      @onPost?()
      $$textarea?.value = ''

  resizeTextarea: (e) =>
    {textareaHeight} = @state.getValue()
    $$textarea = e.target
    $$textarea.style.height = "#{DEFAULT_TEXTAREA_HEIGHT}px"
    newHeight = $$textarea.scrollHeight
    $$textarea.style.height = "#{newHeight}px"
    $$textarea.scrollTop = newHeight
    unless textareaHeight is newHeight
      @state.set textareaHeight: newHeight
      @onResize?()

  getHeightPx: =>
    {textareaHeight} = @state.getValue()
    textareaHeight

  render: =>
    {isTextareaFocused, hasText, textareaHeight} = @state.getValue()

    z '.z-conversation-input-textarea',
        z 'textarea.textarea',
          id: 'textarea'
          key: 'conversation-input-textarea'
          # # for some reason necessary on iOS to get it to focus properly
          # onclick: (e) ->
          #   setTimeout ->
          #     e?.target?.focus()
          #   , 0
          style:
            height: "#{textareaHeight}px"
          placeholder: @model.l.get 'conversationInputTextArea.hintText'
          onkeydown: (e) ->
            if e.keyCode is 13 and not e.shiftKey
              e.preventDefault()
          onkeyup: (e) =>
            if e.keyCode is 13 and not e.shiftKey
              e.preventDefault()
              @postMessage()
          oninput: (e) =>
            @resizeTextarea e
            @setMessageFromEvent e
          ontouchstart: (e) =>
            isFocused = e.target is document.activeElement
            if isFocused
              # so text can be selected
              @toggleIScroll? 'disable'
            unless Environment.isGameApp config.GAME_KEY
              @model.window.pauseResizing()
          ontouchend: (e) =>
            isFocused = e.target is document.activeElement
            # weird bug causes textarea to sometimes not focus
            unless isFocused
              e?.target.focus()
            @toggleIScroll? 'enable'
          onmousedown: (e) =>
            isFocused = e.target is document.activeElement
            if isFocused
              @toggleIScroll? 'disable'
          onmouseup: =>
            @toggleIScroll? 'enable'
          onfocus: =>
            unless Environment.isGameApp config.GAME_KEY
              @model.window.pauseResizing()
            clearTimeout @blurTimeout
            @isTextareaFocused.next true
            @onResize?()
          onblur: (e) =>
            @toggleIScroll? 'enable'
            @blurTimeout = setTimeout =>
              isFocused = e.target is document.activeElement
              unless isFocused
                unless Environment.isGameApp config.GAME_KEY
                  @model.window.resumeResizing()
                @isTextareaFocused.next false
            , 350

        z '.right-icons',
          z '.send-icon', {
            onclick: @postMessage
          },
            z @$sendIcon,
              icon: 'send'
              hasRipple: true
              color: if hasText \
                     then colors.$white
                     else colors.$white54
