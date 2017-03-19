config = require '../config'

module.exports = class Group
  namespace: 'groups'

  constructor: ({@auth}) -> null

  create: ({name, description, badgeId, background, mode}) =>
    @auth.call "#{@namespace}.create", {
      name, description, badgeId, background, mode
    }, {invalidateAll: true}

  getAll: ({filter} = {}) =>
    @auth.stream "#{@namespace}.getAll", {filter}

  getById: (id) =>
    @auth.stream "#{@namespace}.getById", {id}

  joinById: (id) =>
    @auth.call "#{@namespace}.joinById", {id}, {
      invalidateAll: true
    }

  leaveById: (id) =>
    @auth.call "#{@namespace}.leaveById", {id}, {
      invalidateAll: true
    }

  inviteById: (id, {userIds}) =>
    @auth.call "#{@namespace}.inviteById", {id, userIds}, {invalidateAll: true}

  updateById: (id, {name, description, badgeId, background, mode}) =>
    @auth.call "#{@namespace}.updateById", {
      id, name, description, badgeId, background, mode
    }, {invalidateAll: true}

  getDisplayName: (group) ->
    group?.name or 'Nameless'

  hasPermission: (group, user, {level} = {}) ->
    userId = user?.id
    level ?= 'member'

    unless userId and group
      return false

    return switch level
      when 'admin'
      then group.creatorId is userId
      # member
      else group.userIds?.indexOf(userId) isnt -1 or group.id is config.MAIN_GROUP_ID
