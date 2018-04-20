module.exports = class Product
  namespace: 'products'

  constructor: ({@auth}) -> null
  getAll: =>
    @auth.stream "#{@namespace}.getAll"

  getAllByGroupId: (groupId) =>
    @auth.stream "#{@namespace}.getAllByGroupId", {groupId}

  buy: (options) =>
    @auth.call "#{@namespace}.buy", options, {invalidateAll: true}
