z = require 'zorium'
_find = require 'lodash/find'
_map = require 'lodash/map'
_filter = require 'lodash/filter'
_takeRight = require 'lodash/takeRight'
_isEmpty = require 'lodash/isEmpty'
Rx = require 'rx-lite'

FormatService = require '../../services/format'
DeckCards = require '../deck_cards'
UiCard = require '../ui_card'
PlayerDeckStats = require '../player_deck_stats'
Dropdown = require '../dropdown'
config = require '../../config'
colors = require '../../colors'

if window?
  require './index.styl'

MIN_GAMES_FOR_GUIDE = 20
MIN_WIN_RATE_FOR_GUIDE = 0.6

module.exports = class ProfileDecks
  constructor: ({@model, @router, user, player}) ->
    @typeValue = new Rx.BehaviorSubject 'all'
    @$dropdown = new Dropdown {value: @typeValue}
    @$postDeckCard = new UiCard()

    playerAndType = Rx.Observable.combineLatest(
      player
      @typeValue
      (vals...) -> vals
    )

    playerDecks = playerAndType.flatMapLatest ([{id}, type]) =>
      @model.clashRoyalePlayerDeck.getAllByPlayerId id, {type, sort: 'recent'}

    @state = z.state {
      me: @model.user.getMe()
      language: @model.l.getLanguage()
      hidePostDeckCard: localStorage?.hidePostDeckCard
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
    {me, currentDeck, otherDecks, language,
      hidePostDeckCard, isPrivate} = @state.getValue()

    currentDeckGamesPlayed = currentDeck?.playerDeck?.wins +
                              currentDeck?.playerDeck?.losses # ignore draws
    currentDeckWinRate = currentDeck?.playerDeck?.wins / currentDeckGamesPlayed
    shouldShowPostDeckCard = currentDeckGamesPlayed >= MIN_GAMES_FOR_GUIDE and
                             currentDeckWinRate >= MIN_WIN_RATE_FOR_GUIDE and
                             language is 'es' and not hidePostDeckCard

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

              if shouldShowPostDeckCard
                # TODO: localstorage and translation
                z @$postDeckCard, {
                  isHighlighted: true
                  text: @model.l.get 'profileDecks.postGuide'
                  cancel:
                    text: @model.l.get 'translateCard.cancelText'
                    onclick: =>
                      localStorage?.hidePostDeckCard = '1'
                      @state.set hidePostDeckCard: true
                  submit:
                    text: @model.l.get 'addGuidePage.title'
                    onclick: =>
                      console.log currentDeck
                      @router.go(
                        "/new-thread/deckGuide/#{currentDeck.playerDeck.id}"
                      )
                }

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
