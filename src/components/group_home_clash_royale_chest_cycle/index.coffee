z = require 'zorium'
_map = require 'lodash/map'

Base = require '../base'
Spinner = require '../spinner'
UiCard = require '../ui_card'
ClashRoyaleChestCycle = require '../clash_royale_chest_cycle'
ProfileRefreshBar = require '../profile_refresh_bar'
GetPlayerTagForm = require '../clash_royale_get_player_tag_form'
FormatService = require '../../services/format'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class GroupHomeClashRoyaleChestCycle
  constructor: ({@model, @router, group, player, @overlay$}) ->
    me = @model.user.getMe()

    player ?= me.switchMap ({id}) =>
      @model.player.getByUserIdAndGameKey id, 'clash-royale'
      .map (player) ->
        return player or {}

    @$spinner = new Spinner()
    @$clashRoyaleChestCycle = new ClashRoyaleChestCycle {
      @model, @router, player
    }
    @$profileRefreshBar = new ProfileRefreshBar {
      @model, @router, player, @overlay$, group, gameKey: 'clash-royale'
    }
    @$getPlayerTagForm = new GetPlayerTagForm {@model, @router}

    @state = z.state {
      group
      player
    }

  getHeight: -> 192

  getCancelButton: -> null

  getSubmitButton: =>
    {group, player} = @state.getValue()

    if player?.id
      {
        text: @model.l.get 'groupHome.viewAllStats'
        onclick: =>
          @model.group.goPath group, 'groupProfile', {@router}
      }


  render: =>
    {group, player} = @state.getValue()

    z '.z-group-home-clash-royale-chest-cycle',
      if player?.id
        [
          z @$clashRoyaleChestCycle
          z @$profileRefreshBar
        ]
      else if player
        z @$getPlayerTagForm
      else
        @$spinner
