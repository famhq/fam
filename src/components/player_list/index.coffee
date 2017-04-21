z = require 'zorium'
_map = require 'lodash/map'

Avatar = require '../avatar'
Icon = require '../icon'
FormatService = require '../../services/format'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class PlayerList
  constructor: ({@model, players, @selectedProfileDialogUser}) ->
    @state = z.state
      players: players.map (players) ->
        _map players, (player) ->
          {
            $avatar: new Avatar()
            $trophyIcon: new Icon()
            $verifiedIcon: new Icon()
            player: player
          }

  render: ({onclick} = {}) =>
    {players} = @state.getValue()

    z '.z-player-list',
      _map players, ({$avatar, $trophyIcon, $verifiedIcon, player}) =>
        z '.player', {
          onclick: =>
            if onclick
              onclick player
            else if player.player?.verifiedUser
              @selectedProfileDialogUser.onNext player.player?.verifiedUser
        },
          if player.rank
            z '.rank', "##{player.rank}"
          else if player.user
            z '.avatar',
              z $avatar,
                user: player.user
                bgColor: colors.$grey200
          z '.content',
            z '.name',
              player.player?.data?.name
              if player.player?.verifiedUserId
                z '.verified',
                  z $verifiedIcon,
                    icon: 'verified'
                    color: colors.$secondary500
                    isTouchTarget: false
                    size: '14px'
            z '.details',
              z '.clan', player.player?.data?.clan?.name
              z '.trophies',
                FormatService.number player.player?.data?.trophies
                z '.icon',
                  z $trophyIcon,
                    icon: 'trophy'
                    isTouchTarget: false
                    size: '14px'
                    color: colors.$white54
