z = require 'zorium'
_map = require 'lodash/map'
_shuffle = require 'lodash/shuffle'
Rx = require 'rx-lite'
supportsWebP = window? and require 'supports-webp'

SearchInput = require '../search_input'
Spinner = require '../spinner'
colors = require '../../colors'

if window?
  require './index.styl'

SEARCH_DEBOUNCE = 300

module.exports = class ConversationInputGifs
  constructor: ({@model, @message, @onPost, currentPanel}) ->
    @searchValue = new Rx.BehaviorSubject null
    debouncedSearchValue = @searchValue.debounce(SEARCH_DEBOUNCE)

    @$searchInput = new SearchInput {@model, @searchValue}
    @$spinner = new Spinner()

    currentPanelAndSearchValue = Rx.Observable.combineLatest(
      currentPanel
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
        search.map (results) -> _shuffle results?.data
      else
        Rx.Observable.just null

    @state = z.state
      gifs: gifs
      isLoadingGifs: false
      windowSize: @model.window.getSize()

  getHeightPx: ->
    156

  render: =>
    {gifs, isLoadingGifs, windowSize} = @state.getValue()

    z '.z-conversation-input-gifs',
      z @$searchInput, {
        isSearchIconRight: true
        height: '36px'
        bgColor: colors.$tertiary500
        placeholder: @model.l.get 'conversationInputGifs.hintText'
      }
      z '.gifs', {
        # style: width: "#{windowSize.width - drawerWidth}px"
        ontouchstart: (e) ->
          e?.stopPropagation()
      },
        if isLoadingGifs
          z @$spinner, {hasTopMargin: false}
        else
          _map gifs, (gif) =>
            fixedHeightImg = gif.images.fixed_height
            height = 100
            width = fixedHeightImg.width / fixedHeightImg.height * height
            z 'img.gif', {
              width: width
              height: height
              onclick: =>
                @message.onNext "![](#{gif.images.fixed_height.url} " +
                              "=#{width}x#{height})"
                @onPost()
              src: if supportsWebP \
                   then gif.images.fixed_height.webp
                   else gif.images.fixed_height.url
            }
