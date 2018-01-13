z = require 'zorium'
_find = require 'lodash/find'
_map = require 'lodash/map'
_filter = require 'lodash/filter'
_takeRight = require 'lodash/takeRight'
_isEmpty = require 'lodash/isEmpty'

FormatService = require '../../services/format'
DeckCards = require '../deck_cards'
PlayerDeckStats = require '../player_deck_stats'
config = require '../../config'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class ProfileMatches
  constructor: ({@model, @router, user, player}) ->
    matches = user.switchMap ({id}) =>
      @model.clashRoyaleMatch.getAllByUserId id, {sort: 'recent'}

    @state = z.state {
      me: @model.user.getMe()
      matches: matches.map (matches) ->
        console.log match
        _map matches, (match) ->
          {
            # playerDeck: playerDeck
            # # player1
            # $deck: new DeckCards {deck: playerDeck?.deck}
            # $stats: new PlayerDeckStats {playerDeck}
          }
    }

  render: =>
    {me, currentDeck, otherDecks, isImporting} = @state.getValue()

    z '.z-profile-history',
      z '.g-grid',
        z '.title',
          @model.l.get 'profileHistory.currentTitle'
        z '.deck',
          z currentDeck?.$deck
          z currentDeck?.$stats

        z '.divider'

        z '.title',
          @model.l.get 'profileHistory.otherDecksTitle'
        if _isEmpty otherDecks
          @model.l.get 'profileHistory.otherDecksEmpty'
        else
          _map otherDecks, ({$deck, $stats}) ->
            z '.deck',
              z $deck
              z $stats
