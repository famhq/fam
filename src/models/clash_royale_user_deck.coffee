module.exports = class ClashRoyaleUserDeck
  namespace: 'clashRoyaleUserDecks'

  constructor: ({@auth}) -> null

  getAllByUserId: (userId, {sort, filter} = {}) =>
    @auth.stream "#{@namespace}.getAllByUserId", {userId, sort, filter}, {
      isErrorable: true
    }

  getByDeckId: (deckId) =>
    @auth.stream "#{@namespace}.getByDeckId", {deckId}

  getFavoritedDeckIds: =>
    @auth.stream "#{@namespace}.getFavoritedDeckIds", {}

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
