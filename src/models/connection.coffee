config = require '../config'

module.exports = class Connection
  namespace: 'connections'

  constructor: ({@auth}) -> null

  getAll: ->
    @auth.stream "#{@namespace}.getAll", {}

  upsert: ({site, token}) ->
    @auth.call "#{@namespace}.upsert", {site, token}, {invalidateAll: true}

  giveUpgradesByGroupId: (groupId) ->
    @auth.call "#{@namespace}.giveUpgradesByGroupId", {groupId}, {invalidateAll: true}
