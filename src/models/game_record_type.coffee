module.exports = class GameRecordType
  namespace: 'gameRecordTypes'

  constructor: ({@auth}) -> null

  getAllByGameId: (gameId, {embed} = {}) =>
    @auth.stream "#{@namespace}.getAllByGameId", {gameId, embed}
