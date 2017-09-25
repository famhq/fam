module.exports = class ClashRoyaleMatch
  namespace: 'clashRoyaleMatches'

  constructor: ({@auth}) -> null

  getAllByUserId: (userId, {sort, filter} = {}) =>
    @auth.stream "#{@namespace}.getAllByUserId", {userId, sort, filter}

  getAllByPlayerId: (playerId, {sort, filter, limit, cursor} = {}) =>
    @auth.stream "#{@namespace}.getAllByPlayerId", {
      playerId, sort, filter, limit, cursor
    }
