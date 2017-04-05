z = require 'zorium'

FormatService = require '../../services/format'
Icon = require '../../components/icon'

if window?
  require './index.styl'

module.exports = class UserDeckStats
  constructor: ({@model, @router, userDeck}) ->
    @state = z.state
      userDeck: userDeck

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


    z '.z-user-deck-stats',
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
        z '.name', 'Cmty win rate'
        z '.value', commWinRate
