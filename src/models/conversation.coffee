Rx = require 'rx-lite'

config = require '../config'

PATH = config.BACKEND_API_URL

module.exports = class Conversation
  constructor: ({@auth}) -> null

  create: ({userIds, groupId}) =>
    @auth.call 'conversations.create', {userIds, groupId}, {
      invalidateAll: true
    }

  getAll: =>
    @auth.stream 'conversations.getAll', {}

  getById: (id) =>
    @auth.stream 'conversations.getById', {id}


  getByGroupId: (groupId) =>
    @auth.stream 'conversations.getByGroupId', {groupId}
