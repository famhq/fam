_defaults = require 'lodash/defaults'

module.exports = class Ban
  namespace: 'bans'

  constructor: ({@auth}) -> null

  getAllByGroupId: (groupId, {duration} = {}) =>
    @auth.stream "#{@namespace}.getAllByGroupId", {duration, groupId}

  banByGroupIdAndUserId: (groupId, userId, {duration} = {}) =>
    @auth.call "#{@namespace}.banByGroupIdAndUserId", {
      userId, groupId, duration
    }, {invalidateAll: true}

  unbanByGroupIdAndUserId: (groupId, userId) =>
    @auth.call "#{@namespace}.unbanByGroupIdAndUserId", {userId, groupId}, {
      invalidateAll: true
    }
