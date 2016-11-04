z = require 'zorium'
Rx = require 'rx-lite'
colors = require '../../colors'
_ = require 'lodash'
log = require 'loga'
Environment = require 'clay-environment'

config = require '../../config'
colors = require '../../colors'
Card = require '../card'
Base = require '../base'

if window?
  require './index.styl'

PADDING = 16
DEFAULT_CARDS_PER_ROW = 4

getCardSizeInfo = ->
  if window?
    # TODO: json file with these vars, stylus uses this
    if window.matchMedia('(min-width: 840px)').matches
      {cardsPerRow: 8}#, itemMargin: 12}
    else
      {cardsPerRow: 4}#, itemMargin: 2}
  else
    {itemsPerRow: DEFAULT_CARDS_PER_ROW}#, itemMargin: 0}

module.exports = class DeckCards extends Base
  constructor: ({@model, @router, deck}) ->
    me = @model.user.getMe()

    unless deck.map
      deck = Rx.Observable.just deck

    deckAndMe = Rx.Observable.combineLatest(
      deck
      me
      (vals...) -> vals
    )

    @cardSizeInfo = getCardSizeInfo()
    @cachedCards = []

    @state = z.state
      me: @model.user.getMe()
      deck: deck
      cardGroups: deckAndMe.map ([deck, me]) =>
        cards = _.map deck.cards, (card, i) =>
          $el = @getCached$ (card?.id or "empty-#{i}"), Card, {card}
          {card, $el}
        _.chunk cards, @cardSizeInfo.cardsPerRow

  afterMount: (@$$el) => null

  render: ({onCardClick, cardsPerRow} = {}) =>
    {me, cardGroups} = @state.getValue()

    cardsPerRow ?= @cardSizeInfo.cardsPerRow
    cardWidth = Math.floor(@$$el?.offsetWidth / cardsPerRow)

    z '.z-deck-cards',
      _.map cardGroups, (cards) ->
        z '.row',
        _.map cards, ({card, $el}) ->
          z '.card', {
            style:
              width: "#{cardWidth}px"
              height: "#{(96 / 76) * cardWidth}px"
          },
            z $el, {onclick: onCardClick, width: cardWidth - 8}
