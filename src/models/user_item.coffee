config = require '../config'
_find = require 'lodash/find'

module.exports = class UserItem
  namespace: 'userItems'

  constructor: ({@auth}) -> null

  getAll: =>
    @auth.stream "#{@namespace}.getAll"

  upgradeByItemKey: (itemKey) =>
    @auth.call "#{@namespace}.upgradeByItemKey", {itemKey}, {
      invalidateAll: true
    }

  isOwnedByUserItemsAndItemKey: (userItems, itemKey) ->
    _find userItems, {itemKey}
