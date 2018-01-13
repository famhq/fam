z = require 'zorium'
_map = require 'lodash/map'
_filter = require 'lodash/filter'
_snakeCase = require 'lodash/snakeCase'

colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class ClashRoyaleChestCycle
  constructor: ({@model, @router, player}) ->
    me = @model.user.getMe()

    @state = z.state {
      player: player
      me: me
    }

  render: ({showAll} = {}) =>
    {me, player} = @state.getValue()

    z '.z-clash-royale-chest-cycle',
      if player?.data?.upcomingChests
        upcomingChests = _filter player?.data.upcomingChests.items, (item) ->
          item.index? and (showAll or item.index < 8)
        z '.chests', {
          ontouchstart: (e) ->
            e?.stopPropagation()
        },
          _map upcomingChests, ({name, index}, i) =>
            chest = _snakeCase name
            z '.chest',
              z 'img',
                src: "#{config.CDN_URL}/chests/#{chest}.png"
                width: 90
                height: 90
              if showAll
                z '.count',
                  if index is 0
                  then @model.l.get('general.next')
                  else "+#{index}"
