module.exports = class ClashRoyaleDeck
  namespace: 'clashRoyaleDecks'

  constructor: ({@auth}) -> null

  getAll: ({sort, filter} = {}) =>
    @auth.stream "#{@namespace}.getAll", {sort, filter}

  getById: (id) =>
    @auth.stream "#{@namespace}.getById", {id}

  getPopular: ({gameType} = {}) =>
    console.log 'get pop', gameType
    @auth.stream "#{@namespace}.getPopular", {gameType}
