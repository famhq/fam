module.exports = class ClanRecordType
  namespace: 'clanRecordTypes'

  constructor: ({@auth}) -> null

  getAllByClanIdAndGameKey: (clanId, gameKey, {embed} = {}) =>
    @auth.stream "#{@namespace}.getAllByClanIdAndGameKey", {
      clanId, gameKey, embed
    }
