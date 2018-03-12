_defaults = require 'lodash/defaults'

config = require '../config'

module.exports = class GroupPage
  namespace: 'groupPages'

  constructor: ({@auth}) -> null

  upsert: (diff) =>
    @auth.call "#{@namespace}.upsert", diff, {
      invalidateAll: true
    }

  getAllByGroupId: (groupId) =>
    @auth.stream "#{@namespace}.getAllByGroupId", {groupId}

  getByGroupIdAndKey: (groupId, key) =>
    @auth.stream "#{@namespace}.getByGroupIdAndKey", {groupId, key}

  deleteByGroupIdAndKey: (groupId, key) =>
    @auth.call "#{@namespace}.deleteByGroupIdAndKey", {groupId, key}, {
      invalidateAll: true
    }
