Rx = require 'rx-lite'

config = require '../config'

PATH = config.BACKEND_API_URL

module.exports = class Group
  constructor: ({@auth}) -> null

  create: ({name, description, badgeId, background}) =>
    @auth.call 'groups.create', {name, description, badgeId, background}, {
      invalidateAll: true
    }

  getAll: ({filter} = {}) =>
    @auth.stream 'groups.getAll', {filter}

  getById: (id) =>
    @auth.stream 'groups.getById', {id}

  joinById: (id) =>
    @auth.call 'groups.joinById', {id}

  updateById: (id, {name, description, badgeId, background}) =>
    @auth.call 'groups.updateById', {
      id, name, description, badgeId, background
    }, {invalidateAll: true}

  hasPermission: (group, user) ->
    console.log group?.userIds
    group?.userIds?.indexOf(user.id) isnt -1
