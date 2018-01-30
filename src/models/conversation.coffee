module.exports = class Conversation
  namespace: 'conversations'

  constructor: ({@auth}) -> null

  create: ({userIds, name, description, groupId}) =>
    @auth.call "#{@namespace}.create", {userIds, name, description, groupId}, {
      invalidateAll: true
    }

  updateById: (id, options) =>
    {name, description, isSlowMode, slowModeCooldown, groupId} = options
    @auth.call "#{@namespace}.updateById", {
      id, name, description, isSlowMode, slowModeCooldown, groupId
    }, {invalidateAll: true}

  getAll: =>
    @auth.stream "#{@namespace}.getAll", {}

  getById: (id) =>
    @auth.stream "#{@namespace}.getById", {id}
