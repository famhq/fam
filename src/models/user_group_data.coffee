_defaults = require 'lodash/defaults'

module.exports = class UserGroupData
  namespace: 'userGroupData'

  constructor: ({@auth}) -> null

  getMeByGroupId: (groupId) =>
    @auth.stream "#{@namespace}.getMeByGroupId", {groupId}

  updateMeByGroupId: (groupId, diff) =>
    @auth.call "#{@namespace}.updateMeByGroupId", _defaults diff, {groupId}, {
      invalidateAll: true
    }
