_defaults = require 'lodash/defaults'

module.exports = class Thread
  namespace: 'threads'

  constructor: ({@auth, @l}) -> null

  create: (diff) =>
    ga? 'send', 'event', 'social_interaction', 'thread', diff.category
    @auth.call "#{@namespace}.create", diff, {invalidateAll: true}

  getAll: ({category, sort, limit, ignoreCache} = {}) =>
    language = @l.getLanguageStr()
    @auth.stream "#{@namespace}.getAll", {category, language, limit, sort}, {
      ignoreCache
    }

  getById: (id, {ignoreCache} = {}) =>
    language = @l.getLanguageStr()
    @auth.stream "#{@namespace}.getById", {id, language}, {ignoreCache}

  voteById: (id, {vote}) =>
    @auth.call "#{@namespace}.voteById", {id, vote}, {invalidateAll: true}

  updateById: (id, diff) =>
    @auth.call "#{@namespace}.updateById", _defaults(diff, {id}), {
      invalidateAll: true
    }

  deleteById: (id) =>
    @auth.call "#{@namespace}.deleteById", {id}, {
      invalidateAll: true
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
