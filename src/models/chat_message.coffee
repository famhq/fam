Rx = require 'rx-lite'

config = require '../config'

PATH = config.BACKEND_API_URL

module.exports = class ChatMessage
  constructor: ({@auth}) -> null

  create: ({body, channel, conversationId, groupId}) =>
    @auth.call 'chatMessages.create', {
      body, channel, conversationId, groupId
    }

  # flag: (id) =>
  #   @auth.call 'chatMessages.flag', {id}

  getByChannel: ({channel}, {ignoreCache} = {}) =>
    @auth.stream 'chatMessages.getByChannel', {channel}, {ignoreCache}

  getByGroupId: ({groupId}, {ignoreCache} = {}) =>
    @auth.stream 'chatMessages.getByGroupId', {groupId}, {ignoreCache}

  getAllByConversationId: (conversationId, {ignoreCache} = {}) =>
    @auth.stream 'chatMessages.getAllByConversationId', {conversationId}, {
      ignoreCache
    }
