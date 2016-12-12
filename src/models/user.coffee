config = require '../config'

module.exports = class User
  DEFAULT_NAME: 'Nameless'

  constructor: ({@auth, @proxy, @exoid}) -> null

  getMe: =>
    @auth.stream 'users.getMe'

  getById: (id) =>
    @auth.stream 'users.getById', {id}

  getByCode: (code) =>
    @auth.stream 'users.getByCode', {code}

  setUsername: (username) =>
    @auth.call 'users.setUsername', {username}, {invalidateAll: true}

  searchByUsername: (username) =>
    @auth.call 'users.searchByUsername', {username}

  # makeMember: =>
  #   @auth.call 'users.makeMember', {}, {invalidateAll: true}

  setFlags: (flags) =>
    @auth.call 'users.setFlags', flags, {invalidateAll: true}

  requestInvite: ({clanTag, username, email, referrerId}) =>
    @auth.call 'users.requestInvite', {clanTag, username, email, referrerId}

  isBlocked: (me, userId) ->
    me?.data?.blockedUserIds?.indexOf(userId) isnt -1

  isFollowing: (me, userId) ->
    me?.data?.followingIds.indexOf(userId) isnt -1

  setAvatarImage: (file) =>
    formData = new FormData()
    formData.append 'file', file, file.name

    @proxy config.API_URL + '/upload', {
      method: 'post'
      qs:
        path: 'users.setAvatarImage'
      body: formData
    }
    # this (exoid.update) doesn't actually work... it'd be nice
    # but it doesn't update existing
    # streams
    # .then @exoid.update
    .then @exoid.invalidateAll

  getDisplayName: (user) =>
    user?.username or @DEFAULT_NAME
