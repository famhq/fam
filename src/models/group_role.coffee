_every = require 'lodash/every'
_find = require 'lodash/find'
_defaults = require 'lodash/defaults'

config = require '../config'

module.exports = class GroupRole
  namespace: 'groupRoles'

  constructor: ({@auth}) -> null

  createByGroupId: (groupId, diff) =>
    @auth.call "#{@namespace}.createByGroupId", _defaults({groupId}, diff), {
      invalidateAll: true
    }

  getAllByGroupId: (groupId) =>
    @auth.stream "#{@namespace}.getAllByGroupId", {groupId}

  updatePermissions: (options) =>
    @auth.call "#{@namespace}.updatePermissions", options, {
      invalidateAll: true
    }
