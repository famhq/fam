z = require 'zorium'
_find = require 'lodash/find'
_map = require 'lodash/map'
_filter = require 'lodash/filter'
_isEmpty = require 'lodash/isEmpty'

FormatService = require '../../services/format'
DeckWithStats = require '../deck_with_stats'
config = require '../../config'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class ProfileHistory
  constructor: ({@model, @router}) ->
    userDecks = @model.clashRoyaleUserDeck.getAll()

    @state = z.state {
      currentDeck: userDecks.map (userDecks) ->
        userDeck = _find userDecks, {isCurrentDeck: true}
        if userDeck?.deck
          {userDeck: userDeck, $el: new DeckWithStats {userDeck}}
      otherDecks: userDecks.map (userDecks) ->
        userDecks = _filter userDecks, ({isCurrentDeck}) ->
          not isCurrentDeck
        _filter _map userDecks, (userDeck) ->
          if userDeck?.deck
            {userDeck: userDeck, $el: new DeckWithStats {userDeck}}
      gameData: @model.userGameData.getMeByGameId config.CLASH_ROYALE_ID
    }

  render: =>
    {currentDeck, otherDecks, gameData} = @state.getValue()

    z '.z-profile-history',
      z '.title',
        'Current deck'
      z '.deck',
        z currentDeck?.$el


      z '.divider'

      z '.title',
        'Other decks'
      if _isEmpty otherDecks
        'No other decks found'
      else
        _map otherDecks, ({$el}) ->
          z '.deck',
            z $el
