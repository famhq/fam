module.exports = class ClashRoyalePlayerDeck
  namespace: 'clashRoyalePlayerDecks'

  constructor: ({@auth}) -> null

  getAllByPlayerId: (playerId, {type, sort, limit} = {}) =>
    @auth.stream "#{@namespace}.getAllByPlayerId", {
      playerId, sort, limit, type
    }, {isErrorable: true}

  getByDeckId: (deckId) =>
    @auth.stream "#{@namespace}.getByDeckId", {deckId}

  getByDeckIdAndPlayerId: (deckId, playerId) =>
    @auth.stream "#{@namespace}.getByDeckIdAndPlayerId", {deckId, playerId}

  incrementByDeckId: (deckId, {state} = {}) =>
    @auth.call "#{@namespace}.incrementByDeckId", {deckId, state}, {
      invalidateAll: true
    }

  create: ({cardIds, cardKeys, name} = {}) =>
    @auth.call "#{@namespace}.create", {
      cardIds, name, cardKeys
    }, {invalidateAll: true}
