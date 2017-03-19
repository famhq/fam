module.exports = class UserGameData
  namespace: 'userGameData'

  constructor: ({@auth}) -> null

  getByUserIdAndGameId: (userId, gameId, {embed} = {}) =>
    @auth.stream "#{@namespace}.getByUserIdAndGameId", {userId, gameId, embed}
