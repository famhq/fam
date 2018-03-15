config = require '../config'

module.exports = class Group
  namespace: 'groups'

  constructor: ({@auth}) -> null

  create: ({name, description, badgeId, background, mode}) =>
    @auth.call "#{@namespace}.create", {
      name, description, badgeId, background, mode
    }, {invalidateAll: true}

  # TODO
  getPath: (group, path, router) ->
    null

  getAll: ({filter, language, embed} = {}) =>
    embed ?= ['conversations', 'star', 'userCount']
    @auth.stream "#{@namespace}.getAll", {filter, language, embed}

  getAllByUserId: (userId, {embed} = {}) =>
    embed ?= ['meGroupUser', 'conversations', 'star', 'userCount']
    @auth.stream "#{@namespace}.getAllByUserId", {userId, embed}

  getById: (id) =>
    @auth.stream "#{@namespace}.getById", {id}

  getByKey: (key) =>
    @auth.stream "#{@namespace}.getByKey", {key}

  getByGameKeyAndLanguage: (gameKey, language) =>
    @auth.stream "#{@namespace}.getByGameKeyAndLanguage", {gameKey, language}

  getAllChannelsById: (id) =>
    @auth.stream "#{@namespace}.getAllChannelsById", {id}

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

  sendNotificationById: (id, {title, description, pathKey}) =>
    @auth.call "#{@namespace}.sendNotificationById", {
      id, title, description, pathKey
      }, {invalidateAll: true}

  updateById: (id, {name, description, badgeId, background, mode}) =>
    @auth.call "#{@namespace}.updateById", {
      id, name, description, badgeId, background, mode
    }, {invalidateAll: true}

  getDisplayName: (group) ->
    group?.name or 'Nameless'

  # TODO: rm completely. atm only used for 'admin' permission
  hasPermission: (group, user, {level} = {}) ->
    userId = user?.id
    level ?= 'member'

    unless userId and group
      return false

    return switch level
      when 'admin'
      then group.creatorId is userId
      # member
      else false # group.userIds?.indexOf(userId) isnt -1 or group.type is 'public'
