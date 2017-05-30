module.exports = class Player
  namespace: 'players'

  constructor: ({@auth}) -> null

  getByUserIdAndGameId: (userId, gameId, {embed} = {}) =>
    @auth.stream "#{@namespace}.getByUserIdAndGameId", {userId, gameId, embed}

  getTop: =>
    @auth.stream "#{@namespace}.getTop", {}

  getMeFollowing: =>
    @auth.stream "#{@namespace}.getMeFollowing", {}

  search: (playerId) =>
    @auth.call "#{@namespace}.search", {playerId}

  verifyMe: ({gold, lo}) =>
    @auth.call "#{@namespace}.verifyMe", {gold, lo}
