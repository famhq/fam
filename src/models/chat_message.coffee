Rx = require 'rx-lite'

config = require '../config'

PATH = config.BACKEND_API_URL

module.exports = class ChatMessage
  constructor: ({@auth}) -> null

  create: ({body, channel, toId}) =>
    @auth.call 'chatMessages.create', {body, channel, toId}, {
      invalidateAll: Boolean toId # toId adds to user.conversationUserIds
    }

  # flag: (id) =>
  #   @auth.call 'chatMessages.flag', {id}

  getAll: ({ignoreCache} = {}) =>
    @auth.stream 'chatMessages.getAll', {}, {ignoreCache}

  getByChannel: ({channel}, {ignoreCache} = {}) =>
    @auth.stream 'chatMessages.getByChannel', {channel}, {ignoreCache}

  getPrivateByUserId: (userId, {ignoreCache} = {}) =>
    @auth.stream 'chatMessages.getPrivateByUserId', {userId}, {ignoreCache}
