module.exports = class ClashRoyaleMatch
  namespace: 'clashRoyaleMatches'

  constructor: ({@auth}) -> null

  getAllByUserId: (userId, {sort, filter} = {}) =>
    @auth.stream "#{@namespace}.getAllByUserId", {userId, sort, filter}
