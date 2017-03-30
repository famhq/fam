config = require '../config'

module.exports = class User
  DEFAULT_NAME: 'Nameless'

  namespace: 'users'

  constructor: ({@auth, @proxy, @exoid}) -> null

  getMe: =>
    @auth.stream "#{@namespace}.getMe"

  getById: (id) =>
    @auth.stream "#{@namespace}.getById", {id}

  getByUsername: (username) =>
    @auth.stream "#{@namespace}.getByUsername", {username}

  getByCode: (code) =>
    @auth.stream "#{@namespace}.getByCode", {code}

  setUsername: (username) =>
    @auth.call "#{@namespace}.setUsername", {username}, {invalidateAll: true}

  searchByUsername: (username) =>
    @auth.call "#{@namespace}.searchByUsername", {username}

  # makeMember: =>
  #   @auth.call "#{@namespace}.makeMember", {}, {invalidateAll: true}

  setFlags: (flags) =>
    @auth.call "#{@namespace}.setFlags", flags, {invalidateAll: true}

  setFlagsById: (id, flags) =>
    @auth.call "#{@namespace}.setFlagsById", {id, flags}, {invalidateAll: true}

  requestInvite: ({clanTag, username, email, referrerId}) =>
    @auth.call "#{@namespace}.requestInvite", {
      clanTag, username, email, referrerId
    }

  isBlocked: (me, userId) ->
    me?.data?.blockedUserIds?.indexOf(userId) isnt -1

  isFollowing: (me, userId) ->
    me?.data?.followingIds?.indexOf(userId) isnt -1

  setAvatarImage: (file) =>
    formData = new FormData()
    formData.append 'file', file, file.name

    @proxy config.API_URL + '/upload', {
      method: 'post'
      qs:
        path: "#{@namespace}.setAvatarImage"
      body: formData
    }
    # this (exoid.update) doesn't actually work... it'd be nice
    # but it doesn't update existing streams
    # .then @exoid.update
    .then @exoid.invalidateAll

  getDisplayName: (user) =>
    user?.username or @DEFAULT_NAME
