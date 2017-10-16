z = require 'zorium'
_map = require 'lodash/map'

Avatar = require '../avatar'
Icon = require '../icon'
FormatService = require '../../services/format'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class PlayerList
  constructor: (options) ->
    {@model, @router, players, @selectedProfileDialogUser, gameKey} = options
    @state = z.state
      gameKey: gameKey
      players: players.map (players) ->
        _map players, (player) ->
          {
            $avatar: new Avatar()
            $trophyIcon: new Icon()
            $verifiedIcon: new Icon()
            player: player
          }

  render: ({onclick} = {}) =>
    {players, gameKey} = @state.getValue()

    z '.z-player-list',
      _map players, ({$avatar, $trophyIcon, $verifiedIcon, player}) =>
        path = @router.get 'player', {gameKey, id: player.tag?.replace('#', '')}
        z 'a.player', {
          href: path
          onclick: (e) =>
            e?.preventDefault()
            if onclick
              onclick player
            else if player.player?.verifiedUser
              @selectedProfileDialogUser.next player.player?.verifiedUser
            else
              @router.goPath path
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
              player.player?.data?.name or player?.name
              if player.player?.isVerified
                z '.verified',
                  z $verifiedIcon,
                    icon: 'verified'
                    color: colors.$secondary500
                    isTouchTarget: false
                    size: '14px'
            z '.details',
              z '.clan', player.player?.data?.clan?.name
              z '.trophies',
                FormatService.number(
                  player.player?.data?.trophies or player?.trophies
                )
                z '.icon',
                  z $trophyIcon,
                    icon: 'trophy'
                    isTouchTarget: false
                    size: '14px'
                    color: colors.$white54
