_defaults = require 'lodash/defaults'
_kebabCase = require 'lodash/kebabCase'

config = require '../config'

module.exports = class Thread
  namespace: 'threads'

  constructor: ({@auth, @l}) -> null

  upsert: (options) =>
    ga? 'send', 'event', 'social_interaction', 'thread', options.thread.category
    @auth.call "#{@namespace}.upsert", options, {invalidateAll: true}

  getAll: (options = {}) =>
    {groupId, gameKey, category, sort, skip, maxTimeUuid,
      limit, ignoreCache} = options
    language = @l.getLanguageStr()
    @auth.stream "#{@namespace}.getAll", {
      groupId, gameKey, category, language, skip, maxTimeUuid, limit, sort
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

  getPath: (thread, router) ->
    # TODO: switch thread to use gameKey and use gameKey from that
    formattedTitle = _kebabCase thread?.title
    router.get 'threadWithTitle', {
      id: thread?.id
      gameKey: config.DEFAULT_GAME_KEY
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
