z = require 'zorium'
_map = require 'lodash/map'
_filter = require 'lodash/filter'
_find = require 'lodash/find'
_meanBy = require 'lodash/meanBy'
Environment = require '../../services/environment'

Spinner = require '../spinner'
AdsenseAd = require '../adsense_ad'
Card = require '../card'
DeckCards = require '../deck_cards'
FormatService = require '../../services/format'
config = require '../../config'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class NewCards
  constructor: ({@model, @router}) ->
    @$spinner = new Spinner()
    @$adsenseAdTop = new AdsenseAd {@model}
    @$adsenseAdBottom = new AdsenseAd {@model}

    mapCard = (card) ->
      {
        card
        popularDecks: _map card?.popularDecks, (popularDeck) ->
          {
            popularDeck: popularDeck
            $deckCards: new DeckCards {deck: popularDeck.deck, cardsPerRow: 8}
          }
      }

    @state = z.state {
      magicArcher: @model.clashRoyaleCard.getByKey 'magic_archer',  {
        embed: ['stats', 'popularDecks', 'bestDecks']
      }
      .map mapCard

      royalGhost: @model.clashRoyaleCard.getByKey 'royal_ghost',  {
        embed: ['stats', 'popularDecks', 'bestDecks']
      }
      .map mapCard
    }

  render: =>
    {magicArcher, royalGhost} = @state.getValue()

    cards = _filter [magicArcher, royalGhost]
    isNativeApp = Environment.isNativeApp config.GAME_KEY
    isMobile = Environment.isMobile()

    z '.z-new-cards',
      z '.g-grid',
        if isMobile and not isNativeApp
          z '.ad',
            z @$adsenseAdTop, {
              slot: 'mobile320x50'
            }
        else if not isMobile and not isNativeApp
          z '.ad',
            z @$adsenseAdTop, {
              slot: 'desktop728x90'
            }
        z '.g-cols',
          _map cards, ({card, popularDecks}, i) =>
            types = [
              'PvP', 'classicChallenge', 'grandChallenge', 'tournament', '2v2',
              'newCardChallenge'
            ]
            z '.g-col.g-xs-12.g-md-6',
              z '.name', @model.clashRoyaleCard.getNameTranslation card.key
              z '.subhead', @model.l.get 'newCards.winRates'
              z '.game-types',
                _map types, (type) =>
                  typeStats = _filter card.stats, {gameType: type}
                  winRate = _meanBy(typeStats, 'winRate') * 100
                  if isNaN winRate
                    winRate = 0
                  roundedWinRate = Math.round(winRate * 100) / 100
                  type = if type is 'PvP' then 'ladder' else type
                  z '.game-type',
                    z '.type', @model.l.get "profileDecks.#{type}"
                    z '.win-rate', "#{roundedWinRate}%"
              z '.subhead', @model.l.get 'newCards.popularDecks'
              z '.popular-decks',
                _map popularDecks, ({popularDeck, $deckCards}) =>
                  allStats = _find popularDeck.deck.stats, {gameType: 'all'}
                  winRate = allStats.winRate * 100
                  roundedWinRate = Math.round(winRate * 100) / 100
                  count = (allStats.wins or 0) + (allStats.losses or 0) +
                            (allStats.draws or 0)
                  z '.popular-deck',
                    z '.deck',
                      z $deckCards, {cardMarginPx: 0}
                    z '.stats',
                      z '.win-rate', "#{roundedWinRate}%"
                      z '.match-count',
                        "(#{FormatService.shortNumber count} " +
                        "#{@model.l.get 'general.games'})"

              if i is 0 and isMobile and not isNativeApp
                z '.ad',
                  z @$adsenseAdBottom, {
                    slot: 'mobile300x250'
                  }
