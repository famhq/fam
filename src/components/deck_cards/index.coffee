z = require 'zorium'
_map = require 'lodash/map'
_chunk = require 'lodash/chunk'
RxObservable = require('rxjs/Observable').Observable
require 'rxjs/add/observable/of'
require 'rxjs/add/operator/map'

Card = require '../card'
Base = require '../base'

if window?
  require './index.styl'

DEFAULT_CARDS_PER_ROW = 4
DESKTOP_CARDS_PER_ROW = 8

getCardSizeInfo = ->
  if window?
    # TODO: json file with these vars, stylus uses this
    if window.matchMedia('(min-width: 768px)').matches
      {cardsPerRow: DESKTOP_CARDS_PER_ROW}
    else
      {cardsPerRow: DEFAULT_CARDS_PER_ROW}
  else
    {cardsPerRow: DEFAULT_CARDS_PER_ROW}

module.exports = class DeckCards extends Base
  constructor: ({deck, @cardsPerRow}) ->
    @cardSizeInfo = getCardSizeInfo()

    if deck.map
      deck = RxObservable.of deck
      cardGroups = deck.map @getCardGroupsFromDeck
    else
      # if not obs, skip state since it flashes on invalidation
      cardGroups = null
      @cardGroups = @getCardGroupsFromDeck deck

    @cachedCards = []

    @state = z.state
      deck: deck
      cardsPerRow: @cardsPerRow
      cardWidth: 0
      cardGroups: cardGroups

  afterMount: (@$$el) =>
    {cardsPerRow} = @state.getValue()
    cardsPerRow ?= @cardSizeInfo.cardsPerRow

    # TODO / HACKY: for some reason offsetWidth is 0 on initial load
    tries = 0
    maxTries = 5
    retryTimeMs = 200
    setWidth = =>
      # chrome seems to round up? so subtract 1
      width = @$$el?.offsetWidth
      if width
        @state.set cardWidth: Math.floor((width - 1) / cardsPerRow)
      else if tries < maxTries
        tries += 1
        setTimeout setWidth, retryTimeMs
      else
        @state.set cardWidth: 320 / cardsPerRow
    setWidth()

  beforeUnmount: ->
    super()

  getCardGroupsFromDeck: (deck) =>
    cards = _map deck?.cards, (card, i) =>
      # can have multiple of same cardId per deck
      $el = @getCached$ ("#{card?.id}#{i}" or "empty-#{i}"), Card, {card}
      {card, $el}
    _chunk cards, @cardsPerRow or @cardSizeInfo.cardsPerRow

  render: ({onCardClick, maxCardWidth, cardMarginPx} = {}) =>
    {cardWidth, cardGroups, cardsPerRow} = @state.getValue()

    cardsPerRow ?= @cardSizeInfo.cardsPerRow
    cardMarginPx ?= 8
    hasNoMargins = cardMarginPx is 0

    if maxCardWidth
      cardWidth = Math.min(maxCardWidth, cardWidth)

    paddingBottom = 100 * (8 / cardsPerRow) / (76 / 96 * cardsPerRow)
    cardWidthWithoutMargins = cardWidth - cardMarginPx
    if cardWidth
      cardSizePercentage = cardWidthWithoutMargins / cardWidth
      paddingBottom *= cardSizePercentage

    z '.z-deck-cards', {
      className: z.classKebab {hasNoMargins}
    },
      z '.cards-wrapper', {
        style:
          paddingBottom: "#{paddingBottom}%"
      },
        z '.cards',
          _map @cardGroups or cardGroups, (cards) ->
            z '.row',
            _map cards, ({card, $el}) ->
              z '.card', {
                style:
                  width: "#{cardWidth}px"
                  height: "#{(96 / 76) * cardWidth}px"
              },
                z $el, {onclick: onCardClick, width: cardWidthWithoutMargins}
