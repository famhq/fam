z = require 'zorium'
_map = require 'lodash/map'
_filter = require 'lodash/filter'
_snakeCase = require 'lodash/snakeCase'

AutoRefreshDialog = require '../auto_refresh_dialog'
Icon = require '../icon'
Dialog = require '../dialog'
DateService = require '../../services/date'
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class ProfileRefreshBar
  constructor: ({@model, @router, player, @overlay$, group}) ->
    me = @model.user.getMe()

    @$autoRefreshDialog = new AutoRefreshDialog {
      @model, @router, @overlay$, group
    }
    @$refreshIcon = new Icon()
    @$dialog = new Dialog()

    @state = z.state {
      player: player
      me: me
      hasUpdatedPlayer: false
      isRefreshing: false
      isAutoRefresh: player.switchMap (player) =>
        @model.player.getIsAutoRefreshByPlayerIdAndGameKey(
          player.id, 'clash-royale'
        )
    }

  beforeUnmount: =>
    @state.set isRefreshing: false, hasUpdatedPlayer: false

  render: =>
    {me, player, hasUpdatedPlayer, isRefreshing,
      isAutoRefresh} = @state.getValue()

    lastUpdateTime = player?.lastUpdateTime

    canRefresh = @model.player.canRefresh player, hasUpdatedPlayer, isRefreshing

    z '.z-profile-refresh-bar',
      z '.time',
        @model.l.get 'profileInfo.lastUpdatedTime'
        ' '
        DateService.fromNow lastUpdateTime
      z '.auto-refresh', {
        onclick: =>
          ga? 'send', 'event', 'verify', 'auto_refresh', 'click'
          @overlay$.next @$autoRefreshDialog
      },
        @model.l.get 'profileInfo.autoRefresh'
        ': '
        if isAutoRefresh
          z '.status',
            @model.l.get 'general.on'
        else
          [
            z '.status',
              z 'div',
                @model.l.get 'general.off'
            z '.info',
              z @$autoRefreshInfoIcon,
                icon: 'help'
                isTouchTarget: false
                size: '14px'
                color: colors.$tertiary900Text
          ]
      z '.refresh',
        z @$refreshIcon,
          icon: if isRefreshing then 'ellipsis' else 'refresh'
          isTouchTarget: false
          color: if canRefresh \
                 then colors.$primary500
                 else colors.$tertiary300
          onclick: =>
            if isRefreshing
              return
            if canRefresh
              tag = player?.id
              @state.set isRefreshing: true
              # re-rendering with new state isn't instantaneous, this is
              canRefresh = false
              @model.clashRoyaleAPI.refreshByPlayerId tag
              .then =>
                @state.set hasUpdatedPlayer: true, isRefreshing: false
            else
              @overlay$.next z @$dialog, {
                isVanilla: true
                $title: @model.l.get 'profileInfo.waitTitle'
                $content: @model.l.get 'profileInfo.waitDescription', {
                  replacements:
                    number: '10'
                }
                onLeave: =>
                  @overlay$.next null
                submitButton:
                  text: @model.l.get 'installOverlay.closeButtonText'
                  onclick: =>
                    @overlay$.next null
              }
