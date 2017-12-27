_every = require 'lodash/every'
_find = require 'lodash/find'
_defaults = require 'lodash/defaults'
_clone = require 'lodash/clone'

config = require '../config'

module.exports = class GroupUser
  namespace: 'groupUsers'

  constructor: ({@auth}) -> null

  addRoleByGroupIdAndUserId: (groupId, userId, roleId) =>
    @auth.call "#{@namespace}.addRoleByGroupIdAndUserId", {
      userId, groupId, roleId
    }, {invalidateAll: true}

  removeRoleByGroupIdAndUserId: (groupId, userId, roleId) =>
    @auth.call "#{@namespace}.removeRoleByGroupIdAndUserId", {
      userId, groupId, roleId
    }, {invalidateAll: true}

  getByGroupIdAndUserId: (groupId, userId) =>
    @auth.stream "#{@namespace}.getByGroupIdAndUserId", {groupId, userId}

  getTopByGroupId: (groupId) =>
    @auth.stream "#{@namespace}.getTopByGroupId", {groupId}

  hasPermission: ({meGroupUser, me, permissions, channelId, roles}) ->
    roles ?= meGroupUser?.roles
    isGlobalModerator = me?.flags?.isModerator
    isGlobalModerator or _every permissions, (permission) ->
      _find roles, (role) ->
        channelPermissions = channelId and role.channelPermissions?[channelId]
        globalPermissions = role.globalPermissions
        permissions = _defaults(
          channelPermissions, globalPermissions, config.DEFAULT_PERMISSIONS
        )
        permissions[permission]
