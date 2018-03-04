z = require 'zorium'
_map = require 'lodash/map'
_filter = require 'lodash/filter'
Environment = require '../../services/environment'

Spinner = require '../spinner'
AdsenseAd = require '../adsense_ad'
Card = require '../card'
config = require '../../config'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class TopDraftCards
  constructor: ({@model, @router}) ->
    @$spinner = new Spinner()
    @$adsenseAd = new AdsenseAd {@model}

    @state = z.state {
      language: @model.l.getLanguage()
      topCards: @model.clashRoyaleCard.getTop {
        gameType: 'newCardChallenge'
      }
      .map (cards) ->
        _filter _map cards, (card) ->
          if card.cardId is 'hog_rider'
            return
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
        _map topCards, ({$card, card}, i) =>
          winRate = card.winRate * 100
          roundedWinRate = Math.round(winRate * 100) / 100
          showAd = i is 10 and
                    Environment.isMobile() and
                    not Environment.isNativeApp(config.GAME_KEY)
          [
            if showAd
              z '.ad',
                z @$adsenseAd, {
                  slot: 'mobile300x250'
                }
            z '.card-row',
              z '.card',
                z $card, {width: 50}
              z '.name',
                @model.clashRoyaleCard.getNameTranslation card.cardId, language
              z '.win-rate',
                "#{roundedWinRate}%"
          ]
