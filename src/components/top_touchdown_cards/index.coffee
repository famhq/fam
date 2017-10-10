z = require 'zorium'
_map = require 'lodash/map'
Rx = require 'rx-lite'

Spinner = require '../spinner'
Card = require '../card'
config = require '../../config'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class TopTouchdownCards
  constructor: ({@model, @router}) ->
    @$spinner = new Spinner()

    @state = z.state {
      language: @model.l.getLanguage()
      topCards: @model.clashRoyaleCard.getTop {
        gameType: 'touchdown2v2DraftPractice'
      }
      .map (cards) ->
        _map cards, (card) ->
          {
            $card: new Card {card}
            card: card
          }
    }

  render: =>
    {language, topCards} = @state.getValue()

    z '.z-top-touchdown-cards',
      z '.g-grid',
        z '.header',
          z '.card'
          z '.name', @model.l.get 'simulator.card'
          z '.win-rate', @model.l.get 'profileInfo.statWinRate'
        _map topCards, ({$card, card}) =>
          winRate = card.winRate * 100
          roundedWinRate = Math.round(winRate * 100) / 100
          z '.card-row',
            z '.card',
              z $card, {width: 50}
            z '.name',
              @model.clashRoyaleCard.getNameTranslation card.cardId, language
            z '.win-rate',
              "#{roundedWinRate}%"
