z = require 'zorium'

Icon = require '../icon'
DeckCards = require '../deck_cards'
FormatService = require '../../services/format'

if window?
  require './index.styl'

module.exports = class DeckInfo
  constructor: ({@model, @router, deck}) ->
    me = @model.user.getMe()
    userDeck = deck.flatMapLatest (deck) =>
      @model.clashRoyaleUserDeck.getByDeckId deck.id

    @$deckCards = new DeckCards {
      @model
      @router
      deck
    }

    @state = z.state
      me: me
      deck: deck
      userDeck: userDeck

  render: =>
    {me, deck, userDeck} = @state.getValue()


    winsAndLosses = userDeck?.wins + userDeck?.losses
    winRate = FormatService.percentage(
      if winsAndLosses and not isNaN winsAndLosses
      then userDeck?.wins / winsAndLosses
      else 0
    )

    commWinsAndLosses = deck?.wins + deck?.losses
    commWinRate = FormatService.percentage(
      if winsAndLosses and not isNaN commWinsAndLosses
      then deck?.wins / commWinsAndLosses
      else 0
    )

    z '.z-deck-info',
      z '.section',
        @$deckCards
        z '.deck-stats',
          z '.elixir', "#{deck?.averageElixirCost} elixir"
          # TODO: arena 8+

      z '.divider'

      z '.section',
        # z '.subhead', 'Deck rating'
        # TODO

        z '.subhead', 'Personal stats'
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

        z '.subhead', 'Community stats'
        z '.stats',
          z '.stat',
            z '.name', 'Win rate'
            z '.value', commWinRate
