Rx = require 'rx-lite'

config = require '../config'

PATH = config.BACKEND_API_URL

module.exports = class Group
  constructor: ({@auth}) -> null

  create: ({body, title}) =>
    @auth.call 'groups.create', {body, title}, {invalidateAll: true}

  getAll: ({ignoreCache} = {}) =>
    @auth.stream 'groups.getAll', {}, {ignoreCache}

  getById: (id, {ignoreCache} = {}) =>
    @auth.stream 'groups.getById', {id}, {ignoreCache}
