module.exports = class ClashRoyaleAPI
  namespace: 'clashRoyaleAPI'

  constructor: ({@auth}) -> null

  refreshByPlayerTag: (playerTag, {isUpdate} = {}) =>
    @auth.call "#{@namespace}.refreshByPlayerTag", {playerTag, isUpdate}, {
      invalidateAll: true
    }

  refreshByClanId: (clanId, {isUpdate} = {}) =>
    @auth.call "#{@namespace}.refreshByClanId", {clanId, isUpdate}, {
      invalidateAll: true
    }
