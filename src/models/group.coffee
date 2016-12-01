Rx = require 'rx-lite'

config = require '../config'

PATH = config.BACKEND_API_URL

module.exports = class Group
  constructor: ({@auth}) -> null

  create: ({name, description, badge}) =>
    @auth.call 'groups.create', {name, description, badge}, {
      invalidateAll: true
    }

  getAll: ({ignoreCache} = {}) =>
    @auth.stream 'groups.getAll', {}, {ignoreCache}

  getById: (id, {ignoreCache} = {}) =>
    @auth.stream 'groups.getById', {id}, {ignoreCache}

  updateById: (id, {name, description, badgeId, background}) =>
    @auth.call 'groups.updateById', {
      id, name, description, badgeId, background
    }, {invalidateAll: true}
