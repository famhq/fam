z = require 'zorium'
_map = require 'lodash/map'
Rx = require 'rx-lite'
supportsWebP = window? and require 'supports-webp'

Icon = require '../icon'
UploadOverlay = require '../upload_overlay'
SearchInput = require '../search_input'
Spinner = require '../spinner'
ConversationImagePreview = require '../conversation_image_preview'
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

DEFAULT_TEXTAREA_HEIGHT = 54
SEARCH_DEBOUNCE = 300

# TODO: move each panel to own component

module.exports = class ConversationTextarea
  constructor: (options) ->
    {@model, @message, @onPost, @onFocus,
      @isTextareaFocused, @overlay$} = options

    @imageData = new Rx.BehaviorSubject null
    @searchValue = new Rx.BehaviorSubject null
    debouncedSearchValue = @searchValue.debounce(SEARCH_DEBOUNCE)

    @$searchInput = new SearchInput {@searchValue}
    @$spinner = new Spinner()
    @$conversationImagePreview = new ConversationImagePreview {
      @imageData
      @overlay$
      @model
      onUpload: ({key, width, height}) =>
        @setMessage "![](local://#{key} =#{width}x#{height})"
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
      {
        $icon: new Icon()
        icon: 'gifs'
        panel: 'gifs'
      }
    ]

    @isTextareaFocused ?= new Rx.BehaviorSubject false

    @currentPanel = new Rx.BehaviorSubject 'text'
    currentPanelAndSearchValue = Rx.Observable.combineLatest(
      @currentPanel
      debouncedSearchValue
      (vals...) -> vals
    )
    gifs = currentPanelAndSearchValue.flatMapLatest ([currentPanel, query]) =>
      if currentPanel is 'gifs'
        query or= 'clash royale'
        @state.set isLoadingGifs: true
        search = @model.gif.search query, {
          limit: 25
          offset: 0
        }
        search.take(1).subscribe =>
          @state.set isLoadingGifs: false
        search
      else
        Rx.Observable.just null

    @state = z.state
      currentPanel: @currentPanel
      isTextareaFocused: @isTextareaFocused
      gifs: gifs
      isLoadingGifs: false
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
    $$textarea.value = ''
    @setMessage ''

  resizeTextarea: (e) ->
    $$textarea = e.target
    $$textarea.style.height = "#{DEFAULT_TEXTAREA_HEIGHT}px"
    $$textarea.style.height = $$textarea.scrollHeight + 'px'
    $$textarea.scrollTop = $$textarea.scrollHeight

  render: ({color, onclick} = {}) =>
    {currentPanel, isTextareaFocused, hasText,
      gifs, isLoadingGifs} = @state.getValue()

    z '.z-conversation-textarea', {
      className: z.classKebab {"is-#{currentPanel}-panel": true}
    },
      z '.g-grid',
        if currentPanel is 'gifs'
          z '.gif-panel',
            z @$searchInput, {
              isSearchIconRight: true
              height: '36px'
              bgColor: colors.$tertiary500
              placeholder: 'Search gifs...'
            }
            z '.gifs', {
              style: width: "#{window?.innerWidth}px"
              ontouchstart: (e) ->
                e?.stopPropagation()
            },
              if isLoadingGifs
                z @$spinner, {hasTopMargin: false}
              else
                _map gifs?.data, (gif) =>
                  fixedHeightImg = gif.images.fixed_height
                  height = 100
                  width = fixedHeightImg.width / fixedHeightImg.height * height
                  z 'img.gif', {
                    width: width
                    height: height
                    onclick: =>
                      @setMessage "![](#{gif.images.fixed_height.url} " +
                                    "=#{width}x#{height})"
                      @postMessage()
                    src: if supportsWebP \
                         then gif.images.fixed_height.webp
                         else gif.images.fixed_height.url
                  }
        else if currentPanel is 'stickers'
          z '.sticker-panel',
            z '.stickers',
              _map config.STICKERS, (sticker) =>
                z '.sticker',
                  onclick: (e) =>
                    @setMessage ":#{sticker}:"
                    @postMessage e
                    @currentPanel.onNext text
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

        z '.bottom-icons', [
          _map @panels, ({$icon, icon, panel, onclick, $uploadOverlay}) =>
            z '.icon',
              z $icon, {
                onclick: onclick or =>
                  @currentPanel.onNext panel
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
          z '.powered-by-giphy'
        ]
