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

    recordTypes = clan.switchMap ({id}) =>
      @model.clanRecordType.getAllByClanIdAndGameKey(
        id
        'clash-royale'
        {embed: ['clanValues']}
      )

    @state = z.state {
      recordTypes: recordTypes.map (recordTypes) ->
        _map recordTypes, (recordType) ->
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
