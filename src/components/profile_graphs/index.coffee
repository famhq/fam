z = require 'zorium'
_map = require 'lodash/map'

FormatService = require '../../services/format'
GraphWidget = require '../graph_widget'
PrimaryButton = require '../primary_button'
config = require '../../config'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class ProfileGraphs
  constructor: ({@model, @router, user}) ->
    @$communityButton = new PrimaryButton()

    @$trophiesGraph = new GraphWidget()
    recordTypes = user.flatMapLatest ({id}) =>
      @model.gameRecordType.getAllByUserIdAndGameId(
        id
        config.CLASH_ROYALE_ID
        {embed: ['meValues']}
      )

    @state = z.state {
      recordTypes: recordTypes.map (recordTypes) ->
        _map recordTypes, (recordType) ->
          {
            recordType
            $graph: new GraphWidget()
          }
    }

  render: =>
    {recordTypes} = @state.getValue()

    z '.z-profile-graphs',
      _map recordTypes, ({recordType, $graph}) ->
        graphSeries = recordType.userValues
        z '.record-type',
          z '.title', 'Trophies'
          z $graph, {
            labels: [recordType.name]
            series: [graphSeries]
            options:
              lineSmooth: false
              axisY:
                onlyInteger: true
                showGrid: true
              axisX:
                showLabel: false
                showGrid: false
          }

      z '.ask',
        'What else do you want us to track? Tell us in the community!'
        z '.button',
          z @$communityButton,
            text: 'Go to community'
            onclick: =>
              @router.go '/community'
