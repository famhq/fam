config = require '../config'

module.exports = class Connection
  namespace: 'connections'

  constructor: ({@auth}) -> null

  getAll: ->
    @auth.stream "#{@namespace}.getAll", {}

  upsert: ({site, token, groupId}) ->
    @auth.call "#{@namespace}.upsert", {site, token, groupId}, {invalidateAll: true}

  giveUpgradesByGroupId: (groupId) ->
    @auth.call "#{@namespace}.giveUpgradesByGroupId", {groupId}, {invalidateAll: true}
