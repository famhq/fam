z = require 'zorium'
_map = require 'lodash/map'
_find = require 'lodash/find'

Base = require '../base'
Spinner = require '../spinner'
UiCard = require '../ui_card'
Dialog = require '../dialog'
ProfileRefreshBar = require '../profile_refresh_bar'
GetPlayerTagForm = require '../fortnite_get_player_tag_form'
FormatService = require '../../services/format'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class GroupHomeFortniteStats
  constructor: ({@model, @router, group, @overlay$, player, @isMe}) ->
    me = @model.user.getMe()

    player ?= me.switchMap ({id}) =>
      @model.player.getByUserIdAndGameKey id, 'fortnite'
      .map (player) ->
        return player or {}

    @$spinner = new Spinner()
    @$profileRefreshBar = new ProfileRefreshBar {
      @model, @router, player, @overlay$, group, gameKey: 'fortnite'
    }
    @$getPlayerTagForm = new GetPlayerTagForm {@model, @router}
    @$uiCard = new UiCard()
    @$shareDialog = new Dialog()

    @state = z.state {
      group
      player
      isShareDialogVisible: not @model.cookie.get 'hasShownForniteShare'
      language: @model.l.getLanguage()
      addon: group.switchMap (group) =>
        @model.addon.getAllByGroupId group.id
        .map (addons) ->
          _find addons, {key: 'stormShieldOne'}
    }

  render: =>
    {group, player, addon, language, isShareDialogVisible} = @state.getValue()

    apiUrl = config.PUBLIC_API_URL
    shareImageSrc =
      "#{apiUrl}/di/fortnite-stats/#{player?.id}/#{language}.png"
    share = =>
      # make request to backend to create image so it gets
      # cached by cloudflare (facebook reqs images to load fast)
      img = new Image()
      img.src = shareImageSrc
      path = "/g/#{group?.key}?referrer=#{encodeURIComponent(player.id)}" +
      "&lang=#{language}"

      @model.portal.call 'share.any', {
        text: ''
        image: shareImageSrc
        path: path # legacy (< 1.5.06)
        url: "https://#{config.HOST}#{path}"
      }

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
        cancel:
          if player?.id
            {
              text: @model.l.get 'general.share'
              onclick: share
            }
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
      if player?.id and isShareDialogVisible and @isMe
        z @$shareDialog,
          isVanilla: true
          isWide: true
          $title: @model.l.get 'general.share'
          $content:
            z '.group-home-fornite-stats_share-dialog',
              z 'p', @model.l.get 'fortnitePlayerStats.share'
              z 'img.preview',
                src: shareImageSrc
          cancelButton:
            text: @model.l.get 'translateCard.cancelText'
            onclick: =>
              @model.cookie.set 'hasShownForniteShare', '1'
              @state.set isShareDialogVisible: false
          submitButton:
            text: @model.l.get 'general.share'
            onclick: =>
              @model.cookie.set 'hasShownForniteShare', '1'
              @state.set isShareDialogVisible: false
              share()
