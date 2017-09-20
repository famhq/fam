z = require 'zorium'
Rx = require 'rx-lite'
_map = require 'lodash/map'
_chunk = require 'lodash/chunk'

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
      deck = Rx.Observable.just deck

    @cardSizeInfo = getCardSizeInfo()
    @cachedCards = []

    @state = z.state
      deck: deck
      cardsPerRow: cardsPerRow
      cardGroups: deck.map (deck) =>
        cards = _map deck?.cards, (card, i) =>
          # can have multiple of same cardId per deck
          $el = @getCached$ ("#{card?.id}#{i}" or "empty-#{i}"), Card, {card}
          {card, $el}
        _chunk cards, cardsPerRow or @cardSizeInfo.cardsPerRow

  afterMount: (@$$el) => null

  render: ({onCardClick, maxCardWidth, cardMarginPx} = {}) =>
    {cardGroups, cardsPerRow} = @state.getValue()

    cardMarginPx ?= 8
    hasNoMargins = cardMarginPx is 0

    cardsPerRow ?= @cardSizeInfo.cardsPerRow
    if cardWidth
      cardWidth = Math.min(
        maxCardWidth, Math.floor(@$$el?.offsetWidth / cardsPerRow)
      )
    else
      cardWidth = Math.floor(@$$el?.offsetWidth / cardsPerRow)

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
