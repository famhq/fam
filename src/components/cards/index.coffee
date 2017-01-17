z = require 'zorium'
Rx = require 'rx-lite'
_isEmpty = require 'lodash/isEmpty'
_map = require 'lodash/map'

Base = require '../base'
Icon = require '../icon'
Card = require '../card'
Spinner = require '../spinner'
FormatService = require '../../services/format'

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
        _map cards, (card) =>
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
        if cards and _isEmpty cards
          'No cards found'
        else if cards
          _map cards, ({card, hasCard, $card, $changeIcon}) =>
            rankChange = card.timeRanges.thisWeek.rank -
                          card.timeRanges.lastWeek.rank

            if rankChange > 0
              rankColor = '#ff0926'
              rankChange = "+#{rankChange}"
              rankIcon = 'expand-more'
            else
              rankColor = '#7ed321'
              rankIcon = 'expand-less'

            verifiedWins = card?.timeRanges.thisWeek.verifiedWins
            totalMatches = (
              verifiedWins + card?.timeRanges.thisWeek.verifiedLosses
            ) or 1
            [
              z '.g-grid',
                @router.link z 'a.card', {
                  href: "/cards/#{card.id}"
                },
                  z '.change'
                  # z '.change', {style: {color: rankColor}},
                  #   if rankChange
                  #     z '.icon',
                  #       z $changeIcon,
                  #         icon: rankIcon
                  #         size: '10px'
                  #         color: rankColor
                  #         isTouchTarget: false
                  #     if rankChange then rankChange
                  z '.image', $card
                  z '.info',
                    z '.name', card.name or 'Nameless'
                    # z '.row',
                    #   z '.left', 'Win Percentage'
                    #   z '.right',
                    #     FormatService.percentage verifiedWins / totalMatches
                    # z '.row',
                    #   z '.left', 'Popularity'
                    #   z '.right',
                    #     FormatService.rank card.timeRanges.thisWeek.rank
              z '.divider'
            ]
        else
          @$spinner
