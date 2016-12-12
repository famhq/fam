module.exports = class ClashRoyaleDeck
  constructor: ({@auth}) -> null

  getAll: ({sort, filter} = {}) =>
    @auth.stream 'clashRoyaleDeck.getAll', {sort, filter}

  getById: (id) =>
    @auth.stream 'clashRoyaleDeck.getById', {id}
