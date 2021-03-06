config = require '../config'

module.exports = class Group
  namespace: 'groups'

  constructor: ({@auth}) -> null

  create: ({name, description, badgeId, background, mode}) =>
    @auth.call "#{@namespace}.create", {
      name, description, badgeId, background, mode
    }, {invalidateAll: true}

  getAll: ({filter, language, embed} = {}) =>
    embed ?= ['conversations', 'star', 'userCount']
    @auth.stream "#{@namespace}.getAll", {filter, language, embed}

  getAllByUserId: (userId, {embed} = {}) =>
    embed ?= ['meGroupUser', 'conversations', 'star', 'userCount']
    @auth.stream "#{@namespace}.getAllByUserId", {userId, embed}

  getById: (id, {autoJoin} = {}) =>
    @auth.stream "#{@namespace}.getById", {id, autoJoin}

  getByKey: (key, {autoJoin} = {}) =>
    @auth.stream "#{@namespace}.getByKey", {key, autoJoin}

  getByGameKeyAndLanguage: (gameKey, language, {autoJoin} = {}) =>
    @auth.stream "#{@namespace}.getByGameKeyAndLanguage", {
      gameKey, language, autoJoin
    }

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

  getPath: (group, key, {replacements, router, language}) ->
    unless router
      return '/'
    subdomain = router.getSubdomain()

    replacements ?= {}
    replacements.groupId = group?.key or group?.id

    path = router.get key, replacements, {language}
    if subdomain is group?.key
      path = path.replace "/#{group?.key}", ''
    path

  goPath: (group, key, {replacements, router, language}) ->
    subdomain = router.getSubdomain()

    replacements ?= {}
    replacements.groupId = group?.key or group?.id

    path = router.get key, replacements, {language}
    if subdomain is group?.key
      path = path.replace "/#{group?.key}", ''
    router.goPath path


  hasGameKey: (group, gameKey) ->
    (group?.gameKeys and group?.gameKeys?.indexOf(gameKey) isnt -1) or
    group?.gameKey is gameKey

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
