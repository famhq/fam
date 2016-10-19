z = require 'zorium'
Rx = require 'rx-lite'
colors = require '../../colors'
_ = require 'lodash'
log = require 'loga'
Environment = require 'clay-environment'

config = require '../../config'
colors = require '../../colors'
Card = require '../card'

if window?
  require './index.styl'

CARDS_PER_ROW = 4
PADDING = 16

module.exports = class DeckCards
  constructor: ({@model, @router, deck}) ->
    me = @model.user.getMe()

    unless deck.map
      deck = Rx.Observable.just deck

    deckAndMe = Rx.Observable.combineLatest(
      deck
      me
      (vals...) -> vals
    )

    @state = z.state
      me: @model.user.getMe()
      cardGroups: deckAndMe.map ([deck, me]) ->
        console.log 'deck', deck
        cards = _.map deck.cards, (card) ->
          {card, $el: new Card({card})}
        _.chunk cards, CARDS_PER_ROW

  afterMount: (@$$el) => null

  render: ({onclick} = {}) =>
    {me, cardGroups} = @state.getValue()

    cardWidth = @$$el?.offsetWidth / CARDS_PER_ROW

    z '.z-deck-cards',
      _.map cardGroups, (cards) ->
        z '.row',
        _.map cards, ({card, $el}) ->
          z '.card', {
            style:
              width: "#{cardWidth}px"
          },
            z $el, {onclick, width: cardWidth - 8}
