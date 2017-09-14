module.exports = class ClashRoyaleAPI
  namespace: 'clashRoyaleAPI'

  constructor: ({@auth}) -> null

  refreshByPlayerId: (playerId, {isLegacy} = {}) =>
    @auth.call "#{@namespace}.refreshByPlayerId", {playerId, isLegacy}, {
      invalidateAll: true
    }

  setByPlayerId: (playerId, {isUpdate} = {}) =>
    @auth.call "#{@namespace}.setByPlayerId", {playerId, isUpdate}, {
      invalidateAll: true
    }

  refreshByClanId: (clanId, {isUpdate} = {}) =>
    @auth.call "#{@namespace}.refreshByClanId", {clanId, isUpdate}, {
      invalidateAll: true
    }
