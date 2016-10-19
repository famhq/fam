config = require '../config'

module.exports = class User
  DEFAULT_NAME: 'Nameless'

  constructor: ({@auth, @proxy, @exoid}) -> null

  getMe: =>
    @auth.stream 'users.getMe'

  getById: (id) =>
    @auth.stream 'users.getById', {id}

  setUsername: (username) =>
    @auth.call 'users.setUsername', {username}, {invalidateAll: true}

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
