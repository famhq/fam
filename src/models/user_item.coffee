config = require '../config'
_find = require 'lodash/find'

module.exports = class UserItem
  namespace: 'userItems'

  constructor: ({@auth}) -> null

  getAll: =>
    @auth.stream "#{@namespace}.getAll"

  getAllByUserId: (userId) =>
    @auth.stream "#{@namespace}.getAllByUserId", {userId}

  upgradeByItemKey: (itemKey) =>
    @auth.call "#{@namespace}.upgradeByItemKey", {itemKey}, {
      invalidateAll: true
    }

  consumeByItemKey: (itemKey, {groupId}) =>
    @auth.call "#{@namespace}.consumeByItemKey", {itemKey, groupId}, {
      invalidateAll: true
    }

  scratchByItemKey: (itemKey, {groupId}) =>
    @auth.call "#{@namespace}.scratchByItemKey", {itemKey, groupId}, {
      invalidateAll: true
    }

  isOwnedByUserItemsAndItemKey: (userItems, itemKey, count) ->
    userItem = _find userItems, {itemKey}
    if count
      userItem?.count >= count
    else
      Boolean userItem
