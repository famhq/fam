Rx = require 'rx-lite'

config = require '../config'

PATH = config.BACKEND_API_URL

module.exports = class Conversation
  constructor: ({@auth}) -> null

  getAll: ({ignoreCache} = {}) =>
    @auth.stream 'conversation.getAll', {}, {ignoreCache}
