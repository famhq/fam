module.exports = class ClashRoyaleDeck
  namespace: 'clashRoyaleDeck'

  constructor: ({@auth}) -> null

  getAll: ({sort, filter} = {}) =>
    @auth.stream "#{@namespace}.getAll", {sort, filter}

  getById: (id) =>
    @auth.stream "#{@namespace}.getById", {id}
