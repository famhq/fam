module.exports = class ClashRoyalePlayerDeck
  namespace: 'clashRoyalePlayerDecks'

  constructor: ({@auth}) -> null

  getAllByPlayerId: (playerId, {type, sort} = {}) =>
    @auth.stream "#{@namespace}.getAllByPlayerId", {playerId, sort, type}, {
      isErrorable: true
    }

  getByDeckId: (deckId) =>
    @auth.stream "#{@namespace}.getByDeckId", {deckId}

  getById: (id) =>
    @auth.stream "#{@namespace}.getById", {id}

  incrementByDeckId: (deckId, {state} = {}) =>
    @auth.call "#{@namespace}.incrementByDeckId", {deckId, state}, {
      invalidateAll: true
    }

  create: ({cardIds, cardKeys, name} = {}) =>
    @auth.call "#{@namespace}.create", {
      cardIds, name, cardKeys
    }, {invalidateAll: true}
