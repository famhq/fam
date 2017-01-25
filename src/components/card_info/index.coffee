z = require 'zorium'
Rx = require 'rx-lite'
_max = require 'lodash/max'
_map = require 'lodash/map'
_find = require 'lodash/find'
_mapValues = require 'lodash/mapValues'
_startCase = require 'lodash/startCase'

colors = require '../../colors'
config = require '../../config'
Icon = require '../icon'
Card = require '../card'
Dropdown = require '../dropdown'
FormatService = require '../../services/format'

if window?
  require './index.styl'

STAT_TO_ICON =
  damagePerSecond: ''
  damage: ''
  skeletonLevel: 'profile'
  goblinLevel: 'profile'
  spawnSpeed: 'date'
  hitpoints: 'health'

module.exports = class CardInfo
  constructor: ({@model, @router, card}) ->
    me = @model.user.getMe()

    @levelValueStreams = new Rx.ReplaySubject 1
    @levelValueStreams.onNext card.map (card) ->
      _max(card.data.levels, 'level')?.level

    @$crownIcon = new Icon()
    @$statsIcon = new Icon()
    @$hpIcon = new Icon()
    @$clockIcon = new Icon()
    @$levelIcon = new Icon()
    @$dropdown = new Dropdown {
      valueStreams: @levelValueStreams
    }
    @$card = new Card({card})

    cardAndLevel = Rx.Observable.combineLatest(
      card
      @levelValueStreams.switch()
      (vals...) -> vals
    )

    @state = z.state
      me: me
      card: card
      selectedLevel: cardAndLevel.map ([card, level]) ->
        level = _find card.data.levels, {level: parseInt(level)}
        _mapValues level, (stat) ->
          {stat, $el: new Icon()}

  render: =>
    {me, card, selectedLevel} = @state.getValue()

    verifiedWins = card?.timeRanges.thisWeek.verifiedWins
    totalMatches = (
      verifiedWins + card?.timeRanges.thisWeek.verifiedLosses
    ) or 1

    lastWeekVerifiedWins = card?.timeRanges.lastWeek.verifiedWins
    lastWeekTotalMatches = (
      verifiedWins + card?.timeRanges.lastWeek.verifiedLosses
    ) or 1

    z '.z-card-info',
      z '.card',
        z @$card, {width: 160}
      z '.stats',
        z '.g-grid',
          z '.row',
            z '.icon',
              z @$crownIcon,
                icon: 'crown'
                color: colors.$tertiary300
                isTouchTarget: false
            z '.stat.bold', 'Win percentage'

          z '.row',
            z '.icon'
            z '.stat', 'Personal average'
            z '.right',
              '??' # FIXME

          # z '.row',
          #   z '.icon'
          #   z '.stat', 'Community average'
          #   z '.right',
          #     FormatService.percentage verifiedWins / totalMatches

          # z '.row',
          #   z '.icon'
          #   z '.stat', 'Last week average'
          #   z '.right',
          #     FormatService.percentage(
          #       lastWeekVerifiedWins / lastWeekTotalMatches
          #     )
          #
          # z '.row',
          #   z '.icon',
          #     z @$statsIcon,
          #       icon: 'stats'
          #       color: colors.$tertiary300
          #       isTouchTarget: false
          #   z '.stat.bold', 'Popularity'
          #   z '.right',
          #     FormatService.rank card?.timeRanges.thisWeek.rank

        z '.divider'

        z '.g-grid',
          z '.row',
            z '.title', 'Stats'
            z '.dropdown',
              z @$dropdown,
                hintText: 'Level'
                isFloating: false
                options: _map card?.data.levels, (level) ->
                  {value: level.level, text: "Level #{level.level}"}
          _map selectedLevel, ({stat, $el}, key) ->
            if key is 'level'
              return
            z '.row',
              z '.icon',
                z $el,
                  icon: STAT_TO_ICON[key]
                  color: colors.$tertiary300
                  isTouchTarget: false
              z '.stat.bold', _startCase key
              z '.right',
                FormatService.number stat
