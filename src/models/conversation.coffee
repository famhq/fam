module.exports = class Conversation
  namespace: 'conversations'

  constructor: ({@auth}) -> null

  create: ({userIds, name, description, groupId}) =>
    @auth.call "#{@namespace}.create", {userIds, name, description, groupId}, {
      invalidateAll: true
    }

  updateById: (id, {name, description, groupId}) =>
    @auth.call "#{@namespace}.updateById", {id, name, description, groupId}, {
      invalidateAll: true
    }

  getAll: =>
    @auth.stream "#{@namespace}.getAll", {}

  getById: (id) =>
    @auth.stream "#{@namespace}.getById", {id}


  getByGroupId: (groupId) =>
    @auth.stream "#{@namespace}.getByGroupId", {groupId}
