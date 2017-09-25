_defaults = require 'lodash/defaults'
_kebabCase = require 'lodash/kebabCase'

module.exports = class Thread
  namespace: 'threads'

  constructor: ({@auth, @l}) -> null

  create: (diff) =>
    ga? 'send', 'event', 'social_interaction', 'thread', diff.category
    @auth.call "#{@namespace}.create", diff, {invalidateAll: true}

  getAll: ({categories, sort, skip, limit, ignoreCache} = {}) =>
    language = @l.getLanguageStr()
    @auth.stream "#{@namespace}.getAll", {
      categories, language, skip, limit, sort
    }, {ignoreCache}

  getById: (id, {ignoreCache} = {}) =>
    language = @l.getLanguageStr()
    @auth.stream "#{@namespace}.getById", {id, language}, {ignoreCache}

  voteById: (id, {vote}) =>
    ga? 'send', 'event', 'social_interaction', 'thread_vote', "#{id}"
    @auth.call "#{@namespace}.voteById", {id, vote}, {invalidateAll: true}

  updateById: (id, diff) =>
    @auth.call "#{@namespace}.updateById", _defaults(diff, {id}), {
      invalidateAll: true
    }

  deleteById: (id) =>
    @auth.call "#{@namespace}.deleteById", {id}, {
      invalidateAll: true
    }

  getPath: (thread) ->
    formattedTitle = _kebabCase thread?.title
    "/thread/#{thread?.id}/v/#{formattedTitle}"

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
