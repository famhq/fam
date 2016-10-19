Rx = require 'rx-lite'

config = require '../config'

PATH = config.BACKEND_API_URL

module.exports = class ThreadMessage
  constructor: ({@auth}) -> null

  create: ({body, threadId}) =>
    @auth.call 'threadMessages.create', {body, threadId}, {invalidateAll: true}
