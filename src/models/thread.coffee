_defaults = require 'lodash/defaults'

module.exports = class Thread
  namespace: 'threads'

  constructor: ({@auth}) -> null

  create: (diff) =>
    @auth.call "#{@namespace}.create", diff, {invalidateAll: true}

  getAll: ({type, ignoreCache} = {}) =>
    @auth.stream "#{@namespace}.getAll", {type}, {ignoreCache}

  getById: (id, {ignoreCache} = {}) =>
    @auth.stream "#{@namespace}.getById", {id}, {ignoreCache}

  voteById: (id, {vote}) =>
    @auth.call "#{@namespace}.voteById", {id, vote}, {invalidateAll: true}

  updateById: (id, diff) =>
    @auth.call "#{@namespace}.updateById", _defaults(diff, {id}), {
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
