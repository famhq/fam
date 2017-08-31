z = require 'zorium'
_map = require 'lodash/map'
_clone = require 'lodash/clone'

PlayerList = require '../player_list'
config = require '../../config'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class ClanMembers
  constructor: ({@model, @router, clan, selectedProfileDialogUser}) ->
    @$playerList = new PlayerList {
      @model
      selectedProfileDialogUser
      players: clan.map ({players}) ->
        players
    }
    @state = z.state {}

  render: =>
    {} = @state.getValue()

    z '.z-clan-members',
      @$playerList
