_defaults = require 'lodash/defaults'

module.exports = class Event
  namespace: 'events'

  constructor: ({@auth}) -> null

  create: (diff) =>
    @auth.call "#{@namespace}.create", diff, {
      invalidateAll: true
    }

  updateById: (id, diff) =>
    @auth.call "#{@namespace}.updateById", _defaults({id}, diff), {
      invalidateAll: true
    }

  joinById: (id) =>
    @auth.call "#{@namespace}.joinById", {id}, {
      invalidateAll: true
    }

  leaveById: (id) =>
    @auth.call "#{@namespace}.leaveById", {id}, {
      invalidateAll: true
    }

  getById: (id, {embed} = {}) =>
    @auth.stream "#{@namespace}.getById", {id, embed}

  getAll: ({sort, filter} = {}) =>
    @auth.stream "#{@namespace}.getAll", {sort, filter}

  getAllByGroupId: (groupId, {embed} = {}) =>
    @auth.stream "#{@namespace}.getAllByGroupId", {groupId, embed}

  deleteById: (id) =>
    @auth.call "#{@namespace}.deleteById", {id}, {
      invalidateAll: true
    }

  hasPermission: (event, user, {level} = {}) ->
    userId = user?.id
    level ?= 'member'

    unless userId and event
      return false

    return switch level
      when 'admin'
      then event.creatorId is userId
      # member
      else event.userIds?.indexOf(userId) isnt -1
