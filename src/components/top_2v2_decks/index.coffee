z = require 'zorium'
_map = require 'lodash/map'
_filter = require 'lodash/filter'
_find = require 'lodash/find'
Environment = require 'clay-environment'

Spinner = require '../spinner'
AdsenseAd = require '../adsense_ad'
DeckCards = require '../deck_cards'
FormatService = require '../../services/format'
config = require '../../config'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class Top2v2Decks
  constructor: ({@model, @router}) ->
    @$spinner = new Spinner()
    @$adsenseAd = new AdsenseAd {@model}

    @state = z.state {
      language: @model.l.getLanguage()
      popularDecks: @model.clashRoyaleDeck.getPopular {
        gameType: '2v2'
      }
      .map (decks) ->
        _filter _map decks, (deck) ->
          {
            $deck: new DeckCards {deck, cardsPerRow: 8}
            deck: deck
          }
    }

  render: =>
    {language, popularDecks} = @state.getValue()

    z '.z-top-2v2-decks',
      z '.g-grid',
        z '.header',
          z '.deck', @model.l.get 'general.deck'
          z '.win-rate', @model.l.get 'profileInfo.statWinRate'
        _map popularDecks, ({$deck, deck}, i) =>
          challengeStats = _find deck.stats, {gameType: '2v2'}
          winRate = (challengeStats?.winRate or 0) * 100
          roundedWinRate = Math.round(winRate * 100) / 100
          showAd = i is 4 and
                    Environment.isMobile() and
                    not Environment.isGameApp(config.GAME_KEY)
          [
            if showAd
              z '.ad',
                z @$adsenseAd, {
                  slot: 'mobile300x250'
                }
            z '.deck-row',
              z '.deck',
                z $deck, {cardMarginPx: 0}
              z '.win-rate',
                z '.win-rate', "#{roundedWinRate}%"
                z '.match-count',
                  "(#{FormatService.shortNumber deck.matchCount} " +
                  "#{@model.l.get 'general.games'})"
          ]
