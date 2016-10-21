z = require 'zorium'
Rx = require 'rx-lite'
colors = require '../../colors'
_isEmpty = require 'lodash/lang/isEmpty'
log = require 'loga'
Environment = require 'clay-environment'
FormatService = require '../../services/format'

config = require '../../config'
colors = require '../../colors'
Base = require '../base'
Icon = require '../icon'
Card = require '../card'
Spinner = require '../spinner'

if window?
  require './index.styl'

CARDS_PER_ROW = 4
PADDING = 16

module.exports = class Cards extends Base
  constructor: ({@model, @router, sort, filter}) ->
    @$spinner = new Spinner()
    @$addIcon = new Icon()

    me = @model.user.getMe()
    cardsAndMe = Rx.Observable.combineLatest(
      @model.clashRoyaleCard.getAll({sort, filter})
      me
      (vals...) -> vals
    )

    @state = z.state
      me: @model.user.getMe()
      cards: cardsAndMe.map ([cards, me]) =>
        console.log 'cards', cards
        _.map cards, (card) =>
          $el = @getCached$ card.id, Card, {@model, @router, card}
          {
            card
            $card: $el
            $changeIcon: new Icon()
          }

  render: =>
    {me, cards} = @state.getValue()


    z '.z-cards',
      z '.cards',
        if cards and _.isEmpty cards
          'No cards found'
        else if cards
          _.map cards, ({card, hasCard, $card, $changeIcon}) =>
            totalMatches = (card?.wins + card?.losses) or 1
            [
              z '.g-grid',
                @router.link z 'a.card', {
                  href: "/cards/#{card.id}"
                },
                  z '.change' # TODO
                  z '.image', $card
                  z '.info',
                    z '.name', card.name or 'Nameless'
                    z '.row',
                      z '.left', 'Win Percentage'
                      z '.right',
                        FormatService.percentage card?.wins / totalMatches
                    z '.row',
                      z '.left', 'Popularity'
                      z '.right', FormatService.rank card.popularity
              z '.divider'
            ]
        else
          @$spinner
