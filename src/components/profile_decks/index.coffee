z = require 'zorium'
_find = require 'lodash/find'
_map = require 'lodash/map'
_filter = require 'lodash/filter'
_takeRight = require 'lodash/takeRight'
_isEmpty = require 'lodash/isEmpty'
Rx = require 'rx-lite'

FormatService = require '../../services/format'
DeckCards = require '../deck_cards'
PlayerDeckStats = require '../player_deck_stats'
Dropdown = require '../dropdown'
config = require '../../config'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class ProfileDecks
  constructor: ({@model, @router, user, player}) ->
    @typeValue = new Rx.BehaviorSubject 'all'
    @$dropdown = new Dropdown {value: @typeValue}

    playerAndType = Rx.Observable.combineLatest(
      player
      @typeValue
      (vals...) -> vals
    )

    playerDecks = playerAndType.flatMapLatest ([{id}, type]) =>
      @model.clashRoyalePlayerDeck.getAllByPlayerId id, {type, sort: 'recent'}

    @state = z.state {
      me: @model.user.getMe()
      isPrivate: playerDecks
      .catch (err) ->
        ga? 'send', 'event', 'deck_err', err.message
        error = JSON.parse err.message
        Rx.Observable.just true
      .map (result) ->
        if result is true
          true
        else
          false
      currentDeck: playerDecks.map (playerDecks) =>
        # playerDeck = _find playerDecks, {isCurrentDeck: true}
        playerDeck = playerDecks?[0]
        if playerDeck?.deck
          {
            playerDeck: playerDeck
            $deck: new DeckCards {deck: playerDeck?.deck}
            $stats: new PlayerDeckStats {@model, playerDeck}
          }
        else
          null
      otherDecks: playerDecks.map (playerDecks) =>
        # playerDecks = _filter playerDecks, ({isCurrentDeck}) ->
        #   not isCurrentDeck
        # _filter _map playerDecks, (playerDeck) ->
        otherDecks = _takeRight(playerDecks, playerDecks?.length - 1)
        _filter _map otherDecks, (playerDeck) =>
          if playerDeck?.deck and not _isEmpty playerDeck?.deck?.cardIds
            {
              playerDeck: playerDeck
              $deck: new DeckCards {deck: playerDeck?.deck}
              $stats: new PlayerDeckStats {@model, playerDeck}
            }
          else
            console.log 'missing deck', playerDeck
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
          z @$dropdown,
            hintText: 'Type'
            isFloating: false
            options: [
              {value: 'all', text: @model.l.get 'profileDecks.all'}
              {value: 'PvP', text: @model.l.get 'profileDecks.ladder'}
              {
                value: 'grandChallenge'
                text: @model.l.get 'profileDecks.grandChallenge'
              }
              {
                value: 'classicChallenge'
                text: @model.l.get 'profileDecks.classicChallenge'
              }
              {
                value: 'tournament'
                text: @model.l.get 'profileDecks.tournament'
              }
              {
                value: '2v2'
                text: @model.l.get 'profileDecks.2v2'
              }
            ]
          if currentDeck
            [
              z '.title',
                @model.l.get 'profileHistory.currentTitle'
              z '.deck',
                z currentDeck?.$deck
                z currentDeck?.$stats

              z '.divider'
            ]

          z '.title',
            @model.l.get 'profileHistory.otherDecksTitle'
          if _isEmpty otherDecks
            @model.l.get 'profileHistory.otherDecksEmpty'
          else
            _map otherDecks, ({$deck, $stats}) ->
              z '.deck',
                z $deck
                z $stats
