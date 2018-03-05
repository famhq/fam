module.exports = class ClashRoyaleAPI
  namespace: 'clashRoyaleAPI'

  constructor: ({@auth}) -> null

  refreshByClanId: (clanId, {isUpdate} = {}) =>
    @auth.call "#{@namespace}.refreshByClanId", {clanId, isUpdate}, {
      invalidateAll: true
    }
