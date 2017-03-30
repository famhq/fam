module.exports = class UserGameData
  namespace: 'userGameData'

  constructor: ({@auth}) -> null

  getByUserIdAndGameId: (userId, gameId, {embed} = {}) =>
    @auth.stream "#{@namespace}.getByUserIdAndGameId", {userId, gameId, embed}

  getTop: =>
    @auth.stream "#{@namespace}.getTop", {}

  getMeFollowing: =>
    @auth.stream "#{@namespace}.getMeFollowing", {}

  search: (playerId) =>
    @auth.call "#{@namespace}.search", {playerId}
