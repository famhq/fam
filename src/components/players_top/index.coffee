z = require 'zorium'
Rx = require 'rx-lite'

PlayerList = require '../player_list'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class PlayersTop
  constructor: ({@model, @router, @selectedProfileDialogUser}) ->
    @$playerList = new PlayerList {
      @model
      @selectedProfileDialogUser
      players: @model.player.getTop()
    }

  render: =>
    z '.z-players-top',
      z '.g-grid',
        z '.subhead', @model.l.get 'playersPage.playersTop'
        z @$playerList, {
          onclick: ({player}) =>
            userId = player?.userIds?[0]
            @router.go "/user/id/#{userId}"
        }
