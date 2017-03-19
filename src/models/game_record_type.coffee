module.exports = class GameRecordType
  namespace: 'gameRecordTypes'

  constructor: ({@auth}) -> null

  getAllByUserIdAndGameId: (userId, gameId, {embed} = {}) =>
    @auth.stream "#{@namespace}.getAllByUserIdAndGameId", {
      userId, gameId, embed
    }
