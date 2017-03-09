z = require 'zorium'
_find = require 'lodash/find'
_map = require 'lodash/map'
_filter = require 'lodash/filter'

FormatService = require '../../services/format'
DeckCards = require '../deck_cards'
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
        if userDeck
          {userDeck: userDeck, $el: new DeckCards {deck: userDeck.deck}}
      otherDecks: userDecks.map (userDecks) ->
        userDecks = _filter userDecks, {isCurrentDeck: false}
        _map userDecks, (deck) ->
          {userDeck: userDeck, $el: new DeckCards {deck: userDeck.deck}}
      gameData: @model.userGameData.getMeByGameId config.CLASH_ROYALE_ID
    }

  render: =>
    {currentDeck, otherDecks, gameData} = @state.getValue()

    console.log currentDeck, otherDecks, gameData

    z '.z-profile-history',
      'History'
      z '.title',
        'Current deck'
      z currentDeck?.$el
