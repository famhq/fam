config = require '../config'

module.exports = class Item
  namespace: 'items'

  constructor: ({@auth}) -> null

  getAllByGroupId: (groupId) =>
    @auth.stream "#{@namespace}.getAllByGroupId", {groupId}
