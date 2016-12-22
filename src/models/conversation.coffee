module.exports = class Conversation
  namespace: 'conversations'

  constructor: ({@auth}) -> null

  create: ({userIds, groupId}) =>
    @auth.call "#{@namespace}.create", {userIds, groupId}, {
      invalidateAll: true
    }

  getAll: =>
    @auth.stream "#{@namespace}.getAll", {}

  getById: (id) =>
    @auth.stream "#{@namespace}.getById", {id}


  getByGroupId: (groupId) =>
    @auth.stream "#{@namespace}.getByGroupId", {groupId}
