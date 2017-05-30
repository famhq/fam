_defaults = require 'lodash/defaults'

module.exports = class Mod
  namespace: 'mods'

  constructor: ({@auth}) -> null

  getAllBanned: ({duration}) =>
    @auth.stream "#{@namespace}.getAllBanned", {duration}

  getAllReportedMessages: ({skipCache} = {}) =>
    @auth.stream "#{@namespace}.getAllReportedMessages", {}, {skipCache}

  unflagById: (id) =>
    @auth.call "#{@namespace}.unflagById", {id}, {invalidateAll: true}

  banByUserId: (userId, {duration, type} = {}) =>
    @auth.call "#{@namespace}.banByUserId", {userId, duration, type}, {
      invalidateAll: true
    }

  unbanByUserId: (userId) =>
    @auth.call "#{@namespace}.unbanByUserId", {userId}, {invalidateAll: true}
