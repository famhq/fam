z = require 'zorium'
_find = require 'lodash/find'
_map = require 'lodash/map'
_filter = require 'lodash/filter'
_takeRight = require 'lodash/takeRight'
_isEmpty = require 'lodash/isEmpty'

FormatService = require '../../services/format'
DeckCards = require '../deck_cards'
UserDeckStats = require '../user_deck_stats'
UiCard = require '../ui_card'
config = require '../../config'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class ProfileHistory
  constructor: ({@model, @router, user}) ->
    userDecks = user.flatMapLatest ({id}) =>
      @model.clashRoyaleUserDeck.getAllByUserId id, {sort: 'recent'}

    @$migrateCard = new UiCard()

    @state = z.state {
      isImporting: false
      me: @model.user.getMe()
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

        # TODO: rm whenever
        # if not localStorage?['hasImported'] and new Date(me?.joinTime) < Date.now() - 3600 * 24
        #   z '.migrate',
        #     z @$migrateCard,
        #       text: 'We moved decks to a new database to improve server performance.
        #             Do you want to import your old decks?'
        #       submit:
        #         text: if isImporting then 'importing...' else 'import'
        #         onclick: =>
        #           @state.set isImporting: true
        #           @model.clashRoyaleUserDeck.import()
        #           .then =>
        #             localStorage?['hasImported'] = '1'
        #             @state.set isImporting: false
