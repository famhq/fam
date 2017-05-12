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

module.exports = class ClanGraphs
  constructor: ({@model, @router, clan}) ->
    @$communityButton = new PrimaryButton()

    recordTypes = clan.flatMapLatest ({id}) =>
      @model.clanRecordType.getAllByClanIdAndGameId(
        id
        config.CLASH_ROYALE_ID
        {embed: ['clanValues']}
      )

    @state = z.state {
      recordTypes: recordTypes.map (recordTypes) ->
        _map recordTypes, (recordType) ->
          console.log recordType
          {
            recordType
            graphSeries: _clone(recordType.clanValues)?.reverse()
            $graph: new GraphWidget()
          }
    }

  render: =>
    {recordTypes} = @state.getValue()

    z '.z-clan-graphs',
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
