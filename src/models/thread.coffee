Rx = require 'rx-lite'

config = require '../config'

PATH = config.BACKEND_API_URL

module.exports = class Thread
  constructor: ({@auth}) -> null

  create: ({body, title}) =>
    @auth.call 'threads.create', {body, title}, {invalidateAll: true}

  getAll: ({ignoreCache} = {}) =>
    @auth.stream 'threads.getAll', {}, {ignoreCache}

  getById: (id, {ignoreCache} = {}) =>
    console.log 'getbyid', id
    @auth.stream 'threads.getById', {id}, {ignoreCache}
