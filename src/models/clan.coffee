module.exports = class Clan
  namespace: 'clan'

  constructor: ({@auth}) -> null

  getById: (id, {embed} = {}) =>
    @auth.stream "#{@namespace}.getById", {id, embed}

  # getTop: =>
  #   @auth.stream "#{@namespace}.getTop", {}
  #
  # getMeFollowing: =>
  #   @auth.stream "#{@namespace}.getMeFollowing", {}
  #
  # search: (playerId) =>
  #   @auth.call "#{@namespace}.search", {playerId}
