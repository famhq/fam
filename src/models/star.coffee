module.exports = class Star
  namespace: 'stars'

  constructor: ({@auth}) -> null

  getByUsername: (username) =>
    @auth.stream "#{@namespace}.getByUsername", {username}

  getAll: =>
    @auth.stream "#{@namespace}.getAll", {}
