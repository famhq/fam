Rx = require 'rx-lite'

config = require '../config'

PATH = config.BACKEND_API_URL

module.exports = class Thread
  constructor: ({@auth}) -> null

  getAll: ({ignoreCache} = {}) =>
    @auth.stream 'threads.getAll', {}, {ignoreCache}
