z = require 'zorium'
_find = require 'lodash/find'
_map = require 'lodash/map'
_filter = require 'lodash/filter'
_takeRight = require 'lodash/takeRight'
_isEmpty = require 'lodash/isEmpty'

FormatService = require '../../services/format'
DeckCards = require '../deck_cards'
UserDeckStats = require '../user_deck_stats'
config = require '../../config'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class ProfileHistory
  constructor: ({@model, @router, user}) ->
    userDecks = user.flatMapLatest ({id}) =>
      @model.clashRoyaleUserDeck.getAllByUserId id

    @state = z.state {
      currentDeck: userDecks.map (userDecks) ->
        # userDeck = _find userDecks, {isCurrentDeck: true}
        userDeck = userDecks?[0]
        if userDeck?.deck
          {
            userDeck: userDeck
            $deck: new DeckCards {deck: userDeck?.deck}
            $stats: new UserDeckStats {userDeck}
          }
      otherDecks: userDecks.map (userDecks) ->
        # userDecks = _filter userDecks, ({isCurrentDeck}) ->
        #   not isCurrentDeck
        # _filter _map userDecks, (userDeck) ->
        otherDecks = _takeRight(userDecks, userDecks?.length - 1)
        _filter _map otherDecks, (userDeck) ->
          if userDeck?.deck
            {
              userDeck: userDeck
              $deck: new DeckCards {deck: userDeck?.deck}
              $stats: new UserDeckStats {userDeck}
            }
          else
            console.log 'missing deck', userDeck
            null
    }

  render: =>
    {currentDeck, otherDecks} = @state.getValue()

    z '.z-profile-history',
      z '.g-grid',
        z '.title',
          'Current deck'
        z '.deck',
          z currentDeck?.$deck
          z currentDeck?.$stats


        z '.divider'

        z '.title',
          'Other decks'
        if _isEmpty otherDecks
          'No other decks found'
        else
          _map otherDecks, ({$deck, $stats}) ->
            z '.deck',
              z $deck
              z $stats
