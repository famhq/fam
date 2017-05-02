z = require 'zorium'
_map = require 'lodash/map'
_clone = require 'lodash/clone'

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

    @$trophiesGraph = new GraphWidget()
    # recordTypes = clan.flatMapLatest ({id}) =>
    #   @model.gameRecordType.getAllByUserIdAndGameId(
    #     id
    #     config.CLASH_ROYALE_ID
    #     {embed: ['meValues']}
    #   )

    @state = z.state {
      # recordTypes: recordTypes.map (recordTypes) ->
      #   _map recordTypes, (recordType) ->
      #     {
      #       recordType
      #       graphSeries: _clone(recordType.clanValues)?.reverse()
      #       $graph: new GraphWidget()
      #     }
    }

  render: =>
    {recordTypes} = @state.getValue()

    z '.z-clan-graphs',
      z '.g-grid',
        z '.empty',
          @model.l.get 'clanGraphs.empty'
