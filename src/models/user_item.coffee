config = require '../config'
_find = require 'lodash/find'

module.exports = class UserItem
  namespace: 'userItems'

  constructor: ({@auth}) -> null

  getAll: =>
    @auth.stream "#{@namespace}.getAll"

  isOwnedByUserItemsAndItemKey: (userItems, itemKey) ->
    _find userItems, {itemKey}
