z = require 'zorium'
_map = require 'lodash/map'
_find = require 'lodash/find'

Base = require '../base'
Spinner = require '../spinner'
UiCard = require '../ui_card'
ProfileRefreshBar = require '../profile_refresh_bar'
GetPlayerTagForm = require '../fortnite_get_player_tag_form'
FormatService = require '../../services/format'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class GroupHomeFortniteStats
  constructor: ({@model, @router, group, @overlay$}) ->
    me = @model.user.getMe()

    player = me.switchMap ({id}) =>
      @model.player.getByUserIdAndGameKey id, 'fortnite'
      .map (player) ->
        return player or {}

    @$spinner = new Spinner()
    @$profileRefreshBar = new ProfileRefreshBar {
      @model, @router, player, @overlay$, group, gameKey: 'fortnite'
    }
    @$getPlayerTagForm = new GetPlayerTagForm {@model, @router}
    @$uiCard = new UiCard()

    @state = z.state {
      group
      player
      addon: group.switchMap (group) =>
        @model.addon.getAllByGroupId group.id
        .map (addons) ->
          _find addons, {key: 'stormShieldOne'}
    }

  render: =>
    {group, player, addon} = @state.getValue()

    z '.z-group-home-fortnite-stats',
      z @$uiCard,
        $title: @model.l.get 'groupHomeFortniteStats.title'
        minHeightPx: 144
        $content:
          z '.z-group-home_ui-card',
            if player?.id
              [
                z '.g-grid',
                  z '.g-cols',
                    z '.g-col.g-sm-4',
                      z '.stat',
                        z '.title', @model.l.get 'profileInfo.statWins'
                        z '.amount',
                          FormatService.number player.data?.lifetimeStats?.wins
                    z '.g-col.g-sm-4',
                      z '.stat',
                        z '.title', @model.l.get 'profileInfo.statMatches'
                        z '.amount',
                          FormatService.number
                            player.data?.lifetimeStats?.matches
                    z '.g-col.g-sm-4',
                      z '.stat',
                        z '.title',  @model.l.get 'profileInfo.statKills'
                        z '.amount',
                          FormatService.number
                            player.data?.lifetimeStats?.kills
                @$profileRefreshBar
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
                @router.openAddon addon, {
                  replacements:
                    username: player.data?.info?.username
                }
            }
