z = require 'zorium'
_map = require 'lodash/map'
_startCase = require 'lodash/startCase'

Icon = require '../icon'
FormatService = require '../../services/format'
config = require '../../config'
colors = require '../../colors'

if window?
  require './index.styl'

getWinRateFromStats = (stats) ->
  winsAndLosses = stats?.wins + stats?.losses
  winRate = FormatService.percentage(
    if winsAndLosses and not isNaN winsAndLosses
    then stats?.wins / winsAndLosses
    else 0
  )

getTypeStats = (stats) ->[
  {
    name: 'Wins'
    value: FormatService.number stats?.wins
  }
  {
    name: 'Losses'
    value: FormatService.number stats?.losses
  }
  {
    name: 'Draws'
    value: FormatService.number stats?.draws
  }
  {
    name: 'Win rate'
    value: getWinRateFromStats stats
  }
  {
    name: 'Crowns earned'
    value: FormatService.number stats?.crownsEarned
  }
  {
    name: 'Crowns lost'
    value: FormatService.number stats?.crownsLost
  }
  {
    name: 'Current win streak'
    value: FormatService.number stats?.currentWinStreak
  }
  {
    name: 'Current loss streak'
    value: FormatService.number stats?.currentLossStreak
  }
  {
    name: 'Max win streak'
    value: FormatService.number stats?.maxWinStreak
  }
  {
    name: 'Max loss streak'
    value: FormatService.number stats?.maxLossStreak
  }
]

module.exports = class ProfileInfo
  constructor: ({@model, @router, user}) ->
    @$trophyIcon = new Icon()
    @$arenaIcon = new Icon()
    @$levelIcon = new Icon()

    @state = z.state {
      gameData: user.flatMapLatest ({id}) =>
        @model.userGameData.getByUserIdAndGameId id, config.CLASH_ROYALE_ID
    }

  render: =>
    {gameData} = @state.getValue()


    metrics =
      stats: [
        {
          name: 'Wins'
          value: FormatService.number gameData?.data?.stats.wins
        }
        {
          name: 'Losses'
          value: FormatService.number gameData?.data?.stats.losses
        }
        {
          name: 'Win rate'
          value: getWinRateFromStats gameData?.data?.stats
        }
        {
          name: 'Current favorite card'
          value: _startCase gameData?.data?.stats.favoriteCard
        }
        {
          name: 'Three crown wins'
          value: FormatService.number gameData?.data?.stats.threeCrowns
        }
        {
          name: 'Cards found'
          value: FormatService.number gameData?.data?.stats.cardsFound
        }
        {
          name: 'Highest trophies'
          value: FormatService.number gameData?.data?.stats.maxTrophies
        }
        {
          name: 'Total donations'
          value: FormatService.number gameData?.data?.stats.totalDonations
        }
      ]
      ladder: getTypeStats gameData?.data?.stats?.ladder
      grandChallenge: getTypeStats gameData?.data?.stats?.grandChallenge
      classicChallenge: getTypeStats gameData?.data?.stats?.classicChallenge

    z '.z-profile-info',
      z '.header',
        z '.g-grid',
          z '.info',
            z '.left',
              z '.name', gameData?.data?.name
              z '.tag', "##{gameData?.playerId}"
            if gameData?.data?.clan
              z '.right',
                z '.clan-name', gameData?.data?.clan.name
                z '.clan-tag', "##{gameData?.data?.clan.tag}"
          z '.g-cols',
            z '.g-col.g-xs-4',
              z '.icon',
                z @$trophyIcon,
                  icon: 'trophy'
                  color: colors.$yellow500
              z '.text', gameData?.data?.trophies
            z '.g-col.g-xs-4',
              z '.icon',
                z @$arenaIcon,
                  icon: 'castle'
                  color: colors.$yellow500
              z '.text', "Arena #{gameData?.data?.arena?.number}"
              if gameData?.data?.league
                z '.text', gameData?.data?.league?.name
            z '.g-col.g-xs-4',
              z '.icon',
                z @$levelIcon,
                  icon: 'crown'
                  color: colors.$yellow500
              z '.text', "Level #{gameData?.data?.level}"
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
