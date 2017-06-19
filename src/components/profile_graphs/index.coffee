z = require 'zorium'
_map = require 'lodash/map'
_clone = require 'lodash/clone'
_camelCase = require 'lodash/camelCase'
Environment = require 'clay-environment'

FormatService = require '../../services/format'
GraphWidget = require '../graph_widget'
PrimaryButton = require '../primary_button'
AdsenseAd = require '../adsense_ad'
config = require '../../config'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class ProfileGraphs
  constructor: ({@model, @router, user}) ->
    @$communityButton = new PrimaryButton()
    @$adsenseAd = new AdsenseAd()

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
        _map recordTypes, ({recordType, graphSeries, $graph}, i) =>
          recordTypeKey = _camelCase(recordType.name)
          [
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
            if i is 0
              if Environment.isMobile() and
                  not Environment.isGameApp(config.GAME_KEY)
                z '.ad',
                  z @$adsenseAd, {
                    slot: 'mobile300x250'
                  }
              else if not Environment.isMobile()
                z '.ad',
                  z @$adsenseAd, {
                    slot: 'desktop728x90'
                  }

          ]
