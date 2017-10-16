z = require 'zorium'
_isEmpty = require 'lodash/isEmpty'

PlayerList = require '../player_list'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class PlayersFollowing
  constructor: ({@model, @router, @selectedProfileDialogUser, gameKey}) ->
    players = @model.player.getMeFollowing()

    @$playerList = new PlayerList {
      @model
      @router
      gameKey
      @selectedProfileDialogUser
      players: players
    }

    @state = z.state {players}

  render: =>
    {players, gameKey} = @state.getValue()

    z '.z-players-following',
      z '.g-grid',
        if players and _isEmpty players
          z '.empty-state',
            z '.image'
            z 'div', @model.l.get 'playersFollowing.emptyDiv1'
            z 'div',
              @model.l.get 'playersFollowing.emptyDiv2'
        else
          [
            z '.subhead', @model.l.get 'playersPage.playersFollowing'
            z @$playerList, {
              onclick: ({player}) =>
                userId = player?.userId
                @router.go 'userById', {gameKey, id: userId}
            }
          ]
