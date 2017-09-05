z = require 'zorium'

Icon = require '../icon'
DeckCards = require '../deck_cards'
FormatService = require '../../services/format'

if window?
  require './index.styl'

module.exports = class DeckInfo
  constructor: ({@model, @router, deck}) ->
    me = @model.user.getMe()
    playerDeck = deck.flatMapLatest (deck) =>
      @model.clashRoyalePlayerDeck.getByDeckId deck.id

    @$deckCards = new DeckCards {
      @model
      @router
      deck
    }

    @state = z.state
      me: me
      deck: deck
      playerDeck: playerDeck

  render: =>
    {me, deck, playerDeck} = @state.getValue()


    winsAndLosses = playerDeck?.wins + playerDeck?.losses
    winRate = FormatService.percentage(
      if winsAndLosses and not isNaN winsAndLosses
      then playerDeck?.wins / winsAndLosses
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
              FormatService.number playerDeck?.wins
              ' / '
              FormatService.number playerDeck?.losses
              ' / '
              FormatService.number playerDeck?.draws
          z '.stat',
            z '.name', 'Win rate'
            z '.value', winRate

        z '.subhead', 'Community stats'
        z '.stats',
          z '.stat',
            z '.name', 'Win rate'
            z '.value', commWinRate
