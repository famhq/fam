z = require 'zorium'

FormatService = require '../../services/format'
DeckCards = require '../deck_cards'

if window?
  require './index.styl'

module.exports = class DeckWithStats
  constructor: ({@model, @router, userDeck}) ->
    @$deckCards = new DeckCards {
      @model
      @router
      deck: if userDeck.map \
            then userDeck.map ({deck}) -> deck
            else userDeck.deck
    }

    @state = z.state {
      userDeck
    }

  render: =>
    {userDeck} = @state.getValue()

    winsAndLosses = userDeck?.wins + userDeck?.losses
    winRate = FormatService.percentage(
      if winsAndLosses and not isNaN winsAndLosses
      then userDeck?.wins / winsAndLosses
      else 0
    )

    commWinsAndLosses = userDeck?.deck?.wins + userDeck?.deck?.losses
    commWinRate = FormatService.percentage(
      if winsAndLosses and not isNaN commWinsAndLosses
      then userDeck?.deck?.wins / commWinsAndLosses
      else 0
    )

    z '.z-deck-with-stats',
      z @$deckCards
      z '.stats',
        z '.stat',
          z '.name', 'W / L / D'
          z '.value',
            FormatService.number userDeck?.wins
            ' / '
            FormatService.number userDeck?.losses
            ' / '
            FormatService.number userDeck?.draws
        z '.stat',
          z '.name', 'Win rate'
          z '.value', winRate
        z '.stat',
          z '.name', 'Comm win rate'
          z '.value', commWinRate
