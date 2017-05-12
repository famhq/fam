module.exports = class ClanRecordType
  namespace: 'clanRecordTypes'

  constructor: ({@auth}) -> null

  getAllByClanIdAndGameId: (clanId, gameId, {embed} = {}) =>
    @auth.stream "#{@namespace}.getAllByClanIdAndGameId", {
      clanId, gameId, embed
    }
