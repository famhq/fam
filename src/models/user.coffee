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

  makeMember: =>
    @auth.call 'users.makeMember', {}, {invalidateAll: true}

  setFlags: (flags) =>
    @auth.call 'users.setFlags', flags, {invalidateAll: true}

  requestInvite: ({clanTag, username, email, referrerId}) =>
    @auth.call 'users.requestInvite', {clanTag, username, email, referrerId}

  isBlocked: (me, userId) ->
    me?.data?.blockedUserIds?.indexOf(userId) isnt -1

  setAvatarImage: (file) =>
    formData = new FormData()
    formData.append 'file', file, file.name

    @proxy config.PULSAR_API_URL + '/upload', {
      method: 'post'
      qs:
        path: 'users.setAvatarImage'
      body: formData
    }
    # this doesn't actually work... it'd be nice, but it doesn't update existing
    # streams
    # .then @exoid.update
    .then @exoid.invalidateAll

  getDisplayName: (user) =>
    user?.username or user?.kikUsername?.toLowerCase() or @DEFAULT_NAME
