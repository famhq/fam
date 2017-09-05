module.exports = class GameRecordType
  namespace: 'gameRecordTypes'

  constructor: ({@auth}) -> null

  getAllByPlayerIdAndGameId: (playerId, gameId, {embed} = {}) =>
    @auth.stream "#{@namespace}.getAllByPlayerIdAndGameId", {
      playerId, gameId, embed
    }
