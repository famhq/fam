z = require 'zorium'
_map = require 'lodash/map'

Base = require '../base'
Spinner = require '../spinner'
UiCard = require '../ui_card'
DeckCards = require '../deck_cards'
PlayerDeckStats = require '../player_deck_stats'
FormatService = require '../../services/format'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class GroupHomeClashRoyaleDecks extends Base
  constructor: ({@model, @router, group, player, @overlay$}) ->
    me = @model.user.getMe()

    @$spinner = new Spinner()
    @$uiCard = new UiCard()

    @state = z.state {
      group
      deck: player.switchMap (player) =>
        @model.clashRoyalePlayerDeck.getAllByPlayerId player.id, {
          type: 'all', sort: 'recent', limit: 1
        }
      .map (playerDecks) =>
        playerDeck = playerDecks?[0]
        if playerDeck?.deck
          $deck = @getCached$ (playerDeck?.deckId), DeckCards, {
            deck: playerDeck?.deck, cardsPerRow: 8
          }
          {
            playerDeck: playerDeck
            $deck: $deck
            $stats: new PlayerDeckStats {@model, playerDeck}
          }
    }

  beforeUnmount: ->
    super()

  render: =>
    {group, deck} = @state.getValue()

    z '.z-group-home-decks',
      z @$uiCard,
        $title: @model.l.get 'profileHistory.currentTitle'
        $content:
          z '.z-group-home_ui-card',
            z '.deck',
              z deck?.$deck, {cardMarginPx: 0}
              z deck?.$stats
        submit:
          text: @model.l.get 'general.viewAll'
          onclick: =>
            @model.group.goPath group, 'groupProfile', {@router}
