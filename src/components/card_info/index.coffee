_ = require 'lodash'
z = require 'zorium'
log = require 'loga'
Rx = require 'rx-lite'

colors = require '../../colors'
config = require '../../config'
Icon = require '../icon'
Card = require '../card'
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

    @$crownIcon = new Icon()
    @$statsIcon = new Icon()
    @$hpIcon = new Icon()
    @$clockIcon = new Icon()
    @$levelIcon = new Icon()
    @$card = new Card({card})

    @state = z.state
      me: me
      card: card
      selectedLevel: card.map (card) ->
        level = _.max card.data.levels, 'level'
        _.mapValues level, (stat) ->
          {stat, $el: new Icon()}

  render: =>
    {me, card, selectedLevel} = @state.getValue()

    totalMatches = (card?.wins + card?.losses) or 1

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

          z '.row',
            z '.icon'
            z '.stat', 'Community average'
            z '.right',
              FormatService.percentage card?.wins / totalMatches

          z '.row',
            z '.icon',
              z @$statsIcon,
                icon: 'stats'
                color: colors.$tertiary300
                isTouchTarget: false
            z '.stat.bold', 'Popularity'
            z '.right',
              FormatService.rank card?.popularity

        z '.divider'

        z '.g-grid',
          z '.row',
            z '.title', 'Stats'
            z '.dropdown', "Level #{selectedLevel?.level.stat}"
          _.map selectedLevel, ({stat, $el}, key) ->
            if key is 'level'
              return
            z '.row',
              z '.icon',
                z $el,
                  icon: STAT_TO_ICON[key]
                  color: colors.$tertiary300
                  isTouchTarget: false
              z '.stat.bold', _.startCase key
              z '.right',
                FormatService.number stat
