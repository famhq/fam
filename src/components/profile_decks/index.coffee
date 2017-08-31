z = require 'zorium'
_find = require 'lodash/find'
_map = require 'lodash/map'
_filter = require 'lodash/filter'
_takeRight = require 'lodash/takeRight'
_isEmpty = require 'lodash/isEmpty'
Rx = require 'rx-lite'

FormatService = require '../../services/format'
DeckCards = require '../deck_cards'
UserDeckStats = require '../user_deck_stats'
UiCard = require '../ui_card'
config = require '../../config'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class ProfileDecks
  constructor: ({@model, @router, user, player}) ->
    userDecks = user.flatMapLatest ({id}) =>
      @model.clashRoyaleUserDeck.getAllByUserId id, {sort: 'recent'}

    @$migrateCard = new UiCard()

    @state = z.state {
      me: @model.user.getMe()
      isPrivate: userDecks
      .catch (err) ->
        ga? 'send', 'event', 'deck_err', err.message
        error = JSON.parse err.message
        Rx.Observable.just true
      .map (result) ->
        if result is true
          true
        else
          false
      currentDeck: userDecks.map (userDecks) =>
        # userDeck = _find userDecks, {isCurrentDeck: true}
        userDeck = userDecks?[0]
        if userDeck?.deck
          {
            userDeck: userDeck
            $deck: new DeckCards {deck: userDeck?.deck}
            $stats: new UserDeckStats {@model, userDeck}
          }
      otherDecks: userDecks.map (userDecks) =>
        # userDecks = _filter userDecks, ({isCurrentDeck}) ->
        #   not isCurrentDeck
        # _filter _map userDecks, (userDeck) ->
        otherDecks = _takeRight(userDecks, userDecks?.length - 1)
        _filter _map otherDecks, (userDeck) =>
          if userDeck?.deck
            {
              userDeck: userDeck
              $deck: new DeckCards {deck: userDeck?.deck}
              $stats: new UserDeckStats {@model, userDeck}
            }
          else
            console.log 'missing deck', userDeck
            null
    }

  render: =>
    {me, currentDeck, otherDecks, isPrivate} = @state.getValue()

    z '.z-profile-decks',
      if isPrivate
        z '.g-grid',
          'This player\'s decks are private'
      else
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
