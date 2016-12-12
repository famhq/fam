module.exports = class ClashRoyaleUserDeck
  constructor: ({@auth}) -> null

  getAll: ({sort, filter} = {}) =>
    @auth.stream 'clashRoyaleUserDeck.getAll', {sort, filter}

  getByDeckId: (deckId) =>
    @auth.stream 'clashRoyaleUserDeck.getByDeckId', {deckId}

  incrementByDeckId: (deckId, {state} = {}) =>
    @auth.call 'clashRoyaleUserDeck.incrementByDeckId', {deckId, state}, {
      invalidateAll: true
    }

  favorite: ({deckId} = {}) =>
    @auth.call 'clashRoyaleUserDeck.favorite', {deckId}, {invalidateAll: true}

  unfavorite: ({deckId} = {}) =>
    @auth.call 'clashRoyaleUserDeck.unfavorite', {deckId}, {invalidateAll: true}

  create: ({cardIds, cardKeys, name} = {}) =>
    @auth.call 'clashRoyaleUserDeck.create', {
      cardIds, name, cardKeys
    }, {invalidateAll: true}
