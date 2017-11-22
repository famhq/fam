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
  constructor: ({deck, cardsPerRow}) ->
    unless deck.map
      deck = RxObservable.of deck

    @cardSizeInfo = getCardSizeInfo()
    @cachedCards = []

    @state = z.state
      deck: deck
      cardsPerRow: cardsPerRow
      cardWidth: 0
      cardGroups: deck.map (deck) =>
        cards = _map deck?.cards, (card, i) =>
          # can have multiple of same cardId per deck
          $el = @getCached$ ("#{card?.id}#{i}" or "empty-#{i}"), Card, {card}
          {card, $el}
        _chunk cards, cardsPerRow or @cardSizeInfo.cardsPerRow

  afterMount: (@$$el) =>
    {cardsPerRow} = @state.getValue()
    cardsPerRow ?= @cardSizeInfo.cardsPerRow
    width = @$$el?.offsetWidth or window?.innerWidth
    @state.set cardWidth: Math.floor(width / cardsPerRow)

  render: ({onCardClick, maxCardWidth, cardMarginPx} = {}) =>
    {cardWidth, cardGroups, cardsPerRow} = @state.getValue()

    cardMarginPx ?= 8
    hasNoMargins = cardMarginPx is 0

    if maxCardWidth
      cardWidth = Math.min(maxCardWidth, cardWidth)

    z '.z-deck-cards', {
      className: z.classKebab {hasNoMargins}
      # seems too tall?
      # style:
      #   minHeight: "#{(96 / 76) * cardWidth}px"
    },
      _map cardGroups, (cards) ->
        z '.row',
        _map cards, ({card, $el}) ->
          z '.card', {
            style:
              width: "#{cardWidth}px"
              height: "#{(96 / 76) * cardWidth}px"
          },
            z $el, {onclick: onCardClick, width: cardWidth - cardMarginPx}
