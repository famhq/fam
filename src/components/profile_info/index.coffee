z = require 'zorium'
_map = require 'lodash/map'
_startCase = require 'lodash/startCase'

Icon = require '../icon'
FormatService = require '../../services/format'
config = require '../../config'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class ProfileInfo
  constructor: ({@model, @router}) ->
    @$trophyIcon = new Icon()
    @$arenaIcon = new Icon()
    @$levelIcon = new Icon()

    @state = z.state {
      gameData: @model.userGameData.getMeByGameId config.CLASH_ROYALE_ID
    }

  render: =>
    {gameData} = @state.getValue()

    console.log gameData

    metrics =
      stats: [
        {
          name: 'Wins'
          value: FormatService.number gameData?.data.stats.wins
        }
        {
          name: 'Current favorite card'
          value: _startCase gameData?.data.stats.favoriteCard
        }
        {
          name: 'Three crown wins'
          value: FormatService.number gameData?.data.stats.threeCrowns
        }
        {
          name: 'Cards found'
          value: FormatService.number gameData?.data.stats.cardsFound
        }
        {
          name: 'Highest trophies'
          value: FormatService.number gameData?.data.stats.maxTrophies
        }
        {
          name: 'Total donations'
          value: FormatService.number gameData?.data.stats.totalDonations
        }
      ]

    z '.z-profile-info',
      z '.header',
        z '.g-grid',
          z '.info',
            z '.left',
              z '.name', gameData?.data.name
              z '.tag', "##{gameData?.playerId}"
            z '.right',
              z '.clan-name', gameData?.data.clan.name
              z '.clan-tag', "##{gameData?.data.clan.tag}"
          z '.g-cols',
            z '.g-col.g-xs-4',
              z '.icon',
                z @$trophyIcon,
                  icon: 'trophy'
                  color: colors.$white12
              z '.text', gameData?.data.trophies
            z '.g-col.g-xs-4',
              z '.icon',
                z @$arenaIcon,
                  icon: 'castle'
                  color: colors.$white12
              z '.text', gameData?.data.arena
            z '.g-col.g-xs-4',
              z '.icon',
                z @$levelIcon,
                  icon: 'crown'
                  color: colors.$white12
              z '.text', gameData?.data.level
      z '.content',
        z '.block',
          _map metrics, (stats, key) ->
            z '.g-grid',
              z '.title',
                _startCase key
              z '.g-cols',
                _map stats, ({name, value}) ->
                  z '.g-col.g-xs-6',
                    z '.name', name
                    z '.value', value
