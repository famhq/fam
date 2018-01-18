z = require 'zorium'
_map = require 'lodash/map'

Base = require '../base'
Spinner = require '../spinner'
UiCard = require '../ui_card'
ClashRoyaleChestCycle = require '../clash_royale_chest_cycle'
ProfileRefreshBar = require '../profile_refresh_bar'
GetPlayerTagForm = require '../get_player_tag_form'
FormatService = require '../../services/format'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class GroupHomeClashRoyaleChestCycle
  constructor: ({@model, @router, group, player, @overlay$}) ->
    me = @model.user.getMe()

    @$spinner = new Spinner()
    @$clashRoyaleChestCycle = new ClashRoyaleChestCycle {
      @model, @router, player
    }
    @$profileRefreshBar = new ProfileRefreshBar {
      @model, @router, player, @overlay$, group
    }
    @$getPlayerTagForm = new GetPlayerTagForm {@model, @router}
    @$uiCard = new UiCard()

    @state = z.state {
      group
      player
    }

  render: =>
    {group, player} = @state.getValue()

    z '.z-group-home-clash-royale-chest-cycle',
      z @$uiCard,
        $title: @model.l.get 'profileChestsPage.title'
        minHeightPx: 200
        $content:
          z '.z-group-home_ui-card',
            if player?.id
              [
                z @$clashRoyaleChestCycle
                z @$profileRefreshBar
              ]
            else if player
              z @$getPlayerTagForm
            else
              @$spinner
        submit:
          if player?.id
            {
              text: @model.l.get 'groupHome.viewAllStats'
              onclick: =>
                @router.go 'groupProfile', {groupId: group.key or group.id}
            }
