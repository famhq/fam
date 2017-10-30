z = require 'zorium'
_map = require 'lodash/map'
_chunk = require 'lodash/chunk'
RxReplaySubject = require('rxjs/ReplaySubject').ReplaySubject
RxObservable = require('rxjs/Observable').Observable
require 'rxjs/add/observable/of'
require 'rxjs/add/operator/map'

Card = require '../card'
Base = require '../base'
Icon = require '../icon'
colors = require '../../colors'

if window?
  require './index.styl'

DEFAULT_CARDS_PER_ROW = 4
DESKTOP_CARDS_PER_ROW = 12

getCardSizeInfo = ->
  if window?
    # TODO: json file with these vars, stylus uses this
    if window.matchMedia('(min-width: 768px)').matches
      {cardsPerRow: DESKTOP_CARDS_PER_ROW}
    else
      {cardsPerRow: DEFAULT_CARDS_PER_ROW}
  else
    {cardsPerRow: DEFAULT_CARDS_PER_ROW}

module.exports = class CardList extends Base
  constructor: ({cards, cardsPerRow, @selectedCardStreams}) ->
    unless cards.map
      cards = RxObservable.of cards

    @cardSizeInfo = getCardSizeInfo()
    @cachedCards = []

    @selectedCardStreams ?= new RxReplaySubject 1

    @$selectedCardIcon = new Icon()

    @state = z.state
      cards: cards
      cardsPerRow: cardsPerRow
      selectedCard: @selectedCardStreams.switch()
      cardGroups: cards.map (cards) =>
        cards = _map cards, (card, i) =>
          $el = @getCached$ (card?.id or "empty-#{i}"), Card, {card}
          {card, $el}
        _chunk cards, cardsPerRow or @cardSizeInfo.cardsPerRow

  afterMount: (@$$el) => null

  render: ({onCardClick, maxCardWidth} = {}) =>
    {cardGroups, cardsPerRow, selectedCard} = @state.getValue()

    cardsPerRow ?= @cardSizeInfo.cardsPerRow
    if cardWidth
      cardWidth = Math.min(
        maxCardWidth, Math.floor(@$$el?.offsetWidth / cardsPerRow)
      )
    else
      cardWidth = Math.floor(@$$el?.offsetWidth / cardsPerRow)

    z '.z-card-list', {
      style:
        minHeight: "#{(96 / 76) * cardWidth}px"
    },
      _map cardGroups, (cards) =>
        z '.row',
        _map cards, ({card, $el}) =>
          z '.card', {
            style:
              width: "#{cardWidth}px"
              height: "#{(96 / 76) * cardWidth}px"
          },
            z $el,
              onclick: (card) =>
                onCardClick card
                @selectedCardStreams.next RxObservable.of card
              width: cardWidth - 8
            if selectedCard?.key is card.key
              z '.selected',
                z '.inner',
                  z @$selectedCardIcon,
                    icon: 'check'
                    isTouchTarget: false
                    color: colors.$white
