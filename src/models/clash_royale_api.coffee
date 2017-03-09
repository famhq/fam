module.exports = class ClashRoyaleAPI
  namespace: 'clashRoyaleAPI'

  constructor: ({@auth}) -> null

  refreshByPlayerTag: (playerTag) =>
    @auth.call "#{@namespace}.refreshByPlayerTag", {playerTag}, {
      invalidateAll: true
    }
