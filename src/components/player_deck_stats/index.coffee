z = require 'zorium'

FormatService = require '../../services/format'
Icon = require '../../components/icon'

if window?
  require './index.styl'

module.exports = class PlayerDeckStats
  constructor: ({@model, @router, playerDeck}) ->
    @state = z.state
      playerDeck: playerDeck

  render: =>
    {playerDeck} = @state.getValue()

    winsAndLosses = playerDeck?.wins + playerDeck?.losses
    winRate = FormatService.percentage(
      if winsAndLosses and not isNaN winsAndLosses
      then playerDeck?.wins / winsAndLosses
      else 0
    )

    commWinsAndLosses = playerDeck?.deck?.wins + playerDeck?.deck?.losses
    commWinRate = FormatService.percentage(
      if winsAndLosses and not isNaN commWinsAndLosses
      then playerDeck?.deck?.wins / commWinsAndLosses
      else 0
    )


    z '.z-user-deck-stats',
      z '.stat',
        z '.name', @model.l.get 'deckInfo.winLossDraw'
        z '.value',
          FormatService.number playerDeck?.wins
          ' / '
          FormatService.number playerDeck?.losses
          ' / '
          FormatService.number playerDeck?.draws
      z '.stat',
        z '.name', @model.l.get 'deckInfo.winPercent'
        z '.value', winRate
      z '.stat',
        z '.name', @model.l.get 'deckInfo.communityWinPercent'
        z '.value', commWinRate
