module.exports = class UserGameData
  namespace: 'userGameData'

  constructor: ({@auth}) -> null

  getMeByGameId: ({gameId, embed} = {}) =>
    @auth.stream "#{@namespace}.getMeByGameId", {gameId, embed}

  updateMeByGameId: (gameId, diff) =>
    @auth.call "#{@namespace}.updateMeByGameId", {gameId, diff}
