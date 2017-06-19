_defaults = require 'lodash/defaults'

module.exports = class Mod
  namespace: 'mods'

  constructor: ({@auth}) -> null

  getAllBanned: ({duration, groupId}) =>
    @auth.stream "#{@namespace}.getAllBanned", {duration, groupId}

  getAllReportedMessages: ({groupId}, {skipCache} = {}) =>
    @auth.stream "#{@namespace}.getAllReportedMessages", {groupId}, {skipCache}

  unflagById: (id) =>
    @auth.call "#{@namespace}.unflagById", {id}, {invalidateAll: true}

  banByUserId: (userId, {groupId, duration, type} = {}) =>
    @auth.call "#{@namespace}.banByUserId", {userId, groupId, duration, type}, {
      invalidateAll: true
    }

  unbanByUserId: (userId, {groupId}) =>
    @auth.call "#{@namespace}.unbanByUserId", {userId, groupId}, {
      invalidateAll: true
    }
