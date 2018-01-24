z = require 'zorium'
_map = require 'lodash/map'
_clone = require 'lodash/clone'

Base = require '../base'
Spinner = require '../spinner'
UiCard = require '../ui_card'
GraphWidget = require '../graph_widget'
FormatService = require '../../services/format'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class GroupHomeAdminStats
  constructor: ({@model, @router, group, player, @overlay$}) ->
    me = @model.user.getMe()

    @$spinner = new Spinner()
    @$uiCard = new UiCard()
    @$fireSpentGraph = new GraphWidget()
    @$fireEarnedGraph = new GraphWidget()

    @state = z.state {
      group
      view: 'fireSpent'
      fireSpentGraphSeries: group.switchMap (group) =>
        @model.groupRecord.getAllByGroupIdAndRecordTypeKey(
          group.id, 'fireSpent'
        ).map (records) ->
          _clone(records)?.reverse()
      fireEarnedGraphSeries: group.switchMap (group) =>
        @model.groupRecord.getAllByGroupIdAndRecordTypeKey(
          group.id, 'fireEarned'
        ).map (records) ->
          _clone(records)?.reverse()
    }

  render: =>
    {group, fireSpentGraphSeries, fireEarnedGraphSeries,
      view} = @state.getValue()

    fireEarnedGraphSeries ?= []
    fireSpentGraphSeries ?= []

    z '.z-group-home-admin-stats', {key: 'home-admin-stats'},
      z @$uiCard,
        $title: @model.l.get 'groupHome.fireStats'
        $content:
          z '.z-group-home-admin-stats_ui-card',
            z '.tabs',
              z '.tab', {
                className: z.classKebab {isSelected: view is 'fireSpent'}
                onclick: =>
                  @state.set view: 'fireSpent'
              },
                @model.l.get 'groupHome.fireSpent'
              z '.tab', {
                className: z.classKebab {isSelected: view is 'fireEarned'}
                onclick: =>
                  @state.set view: 'fireEarned'
              },
                @model.l.get 'groupHome.fireEarned'

            z @$fireEarnedGraph, {
              labels: [@model.l.get "groupHome.#{view}"]
              series: [
                if view is 'fireEarned'
                then fireEarnedGraphSeries
                else fireSpentGraphSeries
              ]
              options:
                lineSmooth: false
                axisY:
                  onlyInteger: true
                  showGrid: true
                axisX:
                  showLabel: false
                  showGrid: false
            }
        # submit:
        #   text: @model.l.get 'earnXp.dailyChatMessageButton'
        #   onclick: =>
        #     @router.go 'groupChat', {groupId: group.key or group.id}
