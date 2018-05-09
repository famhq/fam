z = require 'zorium'
_map = require 'lodash/map'
_startCase = require 'lodash/startCase'
RxReplaySubject = require('rxjs/ReplaySubject').ReplaySubject
RxObservable = require('rxjs/Observable').Observable

Base = require '../base'
UiCard = require '../ui_card'
GroupHomeFortniteStats = require '../group_home_fortnite_stats'
GroupHomeClashRoyaleChestCycle = require '../group_home_clash_royale_chest_cycle'
FormatService = require '../../services/format'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class GroupHomeStats
  constructor: ({@model, @router, group, player, @overlay$, @isMe}) ->
    me = @model.user.getMe()

    @$fortniteStats = new GroupHomeFortniteStats {
      @model, @router, player, group, @overlay$, @isMe
    }
    @$clashRoyaleChestCycle = new GroupHomeClashRoyaleChestCycle {
      @model, @router, player, group, @overlay$, @isMe
    }
    @$uiCard = new UiCard()

    @gameStreams = new RxReplaySubject 1
    @gameStreams.next group.map (group) ->
      group.gameKeys?[0]

    @state = z.state {
      group
      player
      game: @gameStreams.switch()
    }

  render: =>
    {group, player, game} = @state.getValue()

    if game is 'fortnite'
      $component = @$fortniteStats
      title = @model.l.get 'groupHomeFortniteStats.title'
    else
      $component = @$clashRoyaleChestCycle
      title = @model.l.get 'profileChestsPage.title'

    z '.z-group-home-clash-royale-chest-cycle',
      z @$uiCard,
        $title: title
        minHeightPx: $component.getHeight()
        cancel: $component.getCancelButton()
        submit: $component.getSubmitButton()
        $content:
          z '.z-group-home-clash-royale-chest-cycle_ui-card',
            z '.tabs',
              if group?.gameKeys?.length > 1
                _map group?.gameKeys, (gameKey) =>
                  z '.tab', {
                    className: z.classKebab {
                      isSelected: game is gameKey
                    }
                    onclick: =>
                      @gameStreams.next RxObservable.of gameKey
                  },
                    _startCase gameKey
            $component
