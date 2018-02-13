module.exports = class FortnitePlayer
  namespace: 'fortnitePlayers'

  constructor: ({@auth}) -> null

  refreshByPlayerId: (playerId, {isLegacy} = {}) =>
    @auth.call "#{@namespace}.refreshByPlayerId", {playerId, isLegacy}, {
      invalidateAll: true
    }

  setByPlayerId: (playerId, {isUpdate} = {}) =>
    @auth.call "#{@namespace}.setByPlayerId", {playerId, isUpdate}, {
      invalidateAll: true
    }
