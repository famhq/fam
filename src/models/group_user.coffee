_every = require 'lodash/every'
_find = require 'lodash/find'

config = require '../config'

module.exports = class GroupUser
  namespace: 'groupUsers'

  constructor: ({@auth}) -> null

  createModeratorByUsername: ({username, groupId, roleId}) =>
    @auth.call "#{@namespace}.createModeratorByUsername", {
      username, groupId, roleId
    }

  getByGroupIdAndUserId: (groupId, userId) =>
    @auth.stream "#{@namespace}.getByGroupIdAndUserId", {groupId, userId}

  hasPermission: ({meGroupUser, me, permissions}) ->
    isGlobalModerator = me?.flags?.isModerator
    isGlobalModerator or _every permissions, (permission) ->
      _find meGroupUser?.roles, (role) ->
        role.globalPermissions.indexOf(permission) isnt -1
