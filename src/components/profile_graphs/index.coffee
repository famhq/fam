z = require 'zorium'
_map = require 'lodash/map'
_clone = require 'lodash/clone'
_camelCase = require 'lodash/camelCase'

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
            graphSeries: _clone(recordType.userValues)?.reverse()
            $graph: new GraphWidget()
          }
    }

  render: =>
    {recordTypes} = @state.getValue()

    z '.z-profile-graphs',
      z '.g-grid',
        _map recordTypes, ({recordType, graphSeries, $graph}) =>
          recordTypeKey = _camelCase(recordType.name)
          z '.record-type',
            z '.title', @model.l.get "profileGraphs.#{recordTypeKey}"
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
