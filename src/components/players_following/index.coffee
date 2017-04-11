z = require 'zorium'
_isEmpty = require 'lodash/isEmpty'

PlayerList = require '../player_list'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class PlayersFollowing
  constructor: ({@model, @router, @selectedProfileDialogUser}) ->
    players = @model.player.getMeFollowing()

    @$playerList = new PlayerList {
      @model
      @selectedProfileDialogUser
      players: players
    }

    @state = z.state {players}

  render: =>
    {players} = @state.getValue()

    z '.z-players-following',
      z '.g-grid',
        if players and _isEmpty players
          z '.empty-state',
            z '.image'
            z 'div', 'Keep track of your friends or favorite players!'
            z 'div',
              'Find players players to follow through chat or the
              players\' list'
        else
          z @$playerList, {
            onclick: ({player}) =>
              userId = player?.verifiedUserId or player?.userIds?[0]
              @router.go "/user/id/#{userId}"
          }
