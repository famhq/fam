module.exports = class GameRecordType
  namespace: 'gameRecordTypes'

  constructor: ({@auth}) -> null

  getAllByPlayerIdAndGameKey: (playerId, gameKey, {embed} = {}) =>
    @auth.stream "#{@namespace}.getAllByPlayerIdAndGameKey", {
      playerId, gameKey, embed
    }
