module.exports = class ClashRoyaleUserDeck
  namespace: 'clashRoyaleUserDecks'

  constructor: ({@auth}) -> null

  getAll: ({sort, filter} = {}) =>
    @auth.stream "#{@namespace}.getAll", {sort, filter}

  getByDeckId: (deckId) =>
    @auth.stream "#{@namespace}.getByDeckId", {deckId}

  incrementByDeckId: (deckId, {state} = {}) =>
    @auth.call "#{@namespace}.incrementByDeckId", {deckId, state}, {
      invalidateAll: true
    }

  favorite: ({deckId} = {}) =>
    @auth.call "#{@namespace}.favorite", {deckId}, {invalidateAll: true}

  unfavorite: ({deckId} = {}) =>
    @auth.call "#{@namespace}.unfavorite", {deckId}, {invalidateAll: true}

  create: ({cardIds, cardKeys, name} = {}) =>
    @auth.call "#{@namespace}.create", {
      cardIds, name, cardKeys
    }, {invalidateAll: true}
