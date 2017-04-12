z = require 'zorium'
_map = require 'lodash/map'
_startCase = require 'lodash/startCase'
Rx = require 'rx-lite'

config = require '../../config'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class ProfileChests
  constructor: ({@model, @router, player}) ->
    @state = z.state {
      me: @model.user.getMe()
      player: player
    }

  render: =>
    {player, me} = @state.getValue()

    console.log player
    z '.z-profile-chests',
      z '.g-grid',
        z '.title', 'Upcoming chests'
        z '.chests', {
          ontouchstart: (e) ->
            console.log 'ts'
            e?.stopPropagation()
        },
          _map player?.data.chestCycle.chests, (chest) ->
            z 'img.chest',
              src: "#{config.CDN_URL}/chests/#{chest}_chest.png"
              width: 90
              height: 90
        z '.title', 'Chests until'
        z '.chests-until',
          z '.chest',
            z '.image',
              style:
                backgroundImage:
                  "url(#{config.CDN_URL}/chests/super_magical_chest.png)"
            z '.info',
              z '.name', 'Super Magical'
              z '.count',
                "+#{player?.data.chestCycle.countUntil.superMagical}"

          z '.chest',
            z '.image',
              style:
                backgroundImage:
                  "url(#{config.CDN_URL}/chests/legendary_chest.png)"
            z '.info',
              z '.name', 'Legendary'
              z '.count',
                "+#{player?.data.chestCycle.countUntil.legendary}"

          z '.chest',
            z '.image',
              style:
                backgroundImage:
                  "url(#{config.CDN_URL}/chests/epic_chest.png)"
            z '.info',
              z '.name', 'Epic'
              z '.count',
                "+#{player?.data.chestCycle.countUntil.epic}"
