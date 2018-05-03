_defaults = require 'lodash/defaults'
_kebabCase = require 'lodash/kebabCase'

config = require '../config'

module.exports = class Thread
  namespace: 'threads'

  constructor: ({@auth, @l, @group}) -> null

  upsert: (options) =>
    ga? 'send', 'event', 'social_interaction', 'thread', options.thread.category
    @auth.call "#{@namespace}.upsert", options, {invalidateAll: true}

  getAll: (options = {}) =>
    {groupId, category, sort, skip, maxTimeUuid,
      limit, ignoreCache} = options
    language = @l.getLanguageStr()
    @auth.stream "#{@namespace}.getAll", {
      groupId, category, language, skip, maxTimeUuid, limit, sort
    }, {ignoreCache}

  getById: (id, {ignoreCache} = {}) =>
    language = @l.getLanguageStr()
    @auth.stream "#{@namespace}.getById", {id, language}, {ignoreCache}

  updateById: (id, diff) =>
    @auth.call "#{@namespace}.updateById", _defaults(diff, {id}), {
      invalidateAll: true
    }

  deleteById: (id) =>
    @auth.call "#{@namespace}.deleteById", {id}, {
      invalidateAll: true
    }

  pinById: (id) =>
    @auth.call "#{@namespace}.pinById", {id}, {
      invalidateAll: true
    }

  unpinById: (id) =>
    @auth.call "#{@namespace}.unpinById", {id}, {
      invalidateAll: true
    }

  getPath: (thread, group, router) ->
    formattedTitle = _kebabCase thread?.data?.title
    @group.getPath group, 'groupThreadWithTitle', {
      router
      replacements:
        id: thread?.id
        title: formattedTitle or 'thread'
    }

  hasPermission: (thread, user, {level} = {}) ->
    userId = user?.id
    level ?= 'member'

    unless userId and thread
      return false

    return switch level
      when 'admin'
      then thread.creatorId is userId
      # member
      else thread.userIds?.indexOf(userId) isnt -1
