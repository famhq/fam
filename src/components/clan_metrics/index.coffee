z = require 'zorium'
_map = require 'lodash/map'
_startCase = require 'lodash/startCase'
_find = require 'lodash/find'
_filter = require 'lodash/filter'
Rx = require 'rx-lite'

Icon = require '../icon'
FormatService = require '../../services/format'
config = require '../../config'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class ClanInfo
  constructor: ({@model, @router, clan}) ->
    me = @model.user.getMe()

    @state = z.state {
      me: me
      clan: clan
    }

  render: =>
    {clan, me} = @state.getValue()


    metrics =
      info: _filter [
        {
          name: @model.l.get 'clanInfo.weekDonations'
          value: FormatService.number clan?.data?.donations
        }
        {
          name: @model.l.get 'clanInfo.type'
          value: _startCase clan?.data?.type
        }
        {
          name: @model.l.get 'clanInfo.minTrophies'
          value: FormatService.number clan?.data?.minTrophies
        }
        {
          name: @model.l.get 'clanInfo.region'
          value: clan?.data?.region
        }
        if clan?.password
          {
            name: @model.l.get 'general.password'
            value: clan?.password
          }
      ]

    z '.z-clan-metrics',
      _map metrics, (stats, key) ->
        z '.g-grid',
          z '.title',
            _startCase key
          z '.g-cols',
            _map stats, ({name, value}) ->
              z '.g-col.g-xs-6',
                z '.name', name
                z '.value', value
