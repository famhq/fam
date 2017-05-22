module.exports = class ClashRoyaleAPI
  namespace: 'clashRoyaleAPI'

  constructor: ({@auth}) -> null

  refreshByPlayerId: (playerId, {isUpdate} = {}) =>
    @auth.call "#{@namespace}.refreshByPlayerId", {playerId, isUpdate}, {
      invalidateAll: true
    }

  setByPlayerId: (playerId) =>
    @auth.call "#{@namespace}.setByPlayerId", {playerId}, {
      invalidateAll: true
    }

  refreshByClanId: (clanId, {isUpdate} = {}) =>
    @auth.call "#{@namespace}.refreshByClanId", {clanId, isUpdate}, {
      invalidateAll: true
    }
