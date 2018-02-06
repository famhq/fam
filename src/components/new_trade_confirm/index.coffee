z = require 'zorium'
_map = require 'lodash/map'

config = require '../../config'
colors = require '../../colors'
Icon = require '../icon'
Item = require '../item'
Sticker = require '../sticker'
Avatar = require '../avatar'

if window?
  require './index.styl'

ITEM_SIZE = 100

module.exports = class TradeConfirm
  constructor: ({@model, receiveItems, sendItems, to}) ->
    @state = z.state
      me: @model.user.getMe()
      receiveItemsWithComponents: receiveItems.map (receiveItems) =>
        _map receiveItems, (itemInfo) =>
          ItemClass = if itemInfo.item.type is 'sticker' \
                      then Sticker
                      else Item
          {
            itemInfo: itemInfo
            $item: new ItemClass {@model, itemInfo}
          }
      sendItemsWithComponents: sendItems.map (sendItems) =>
        _map sendItems, (itemInfo) =>
          ItemClass = if itemInfo.item.type is 'sticker' \
                      then Sticker
                      else Item
          {
            itemInfo: itemInfo
            $item: new ItemClass {@model, itemInfo}
          }
      toWithComponents: to.map (to) =>
        _map to, (user) =>
          {
            userInfo: user
            $avatar: new Avatar {@model}
          }

  render: =>
    {me, receiveItemsWithComponents, sendItemsWithComponents,
      toWithComponents} = @state.getValue()

    z '.z-new-trade-confirm',
      z '.top',
        z '.g-grid',
          z '.title', @model.l.get 'newTradeConfirm.title'

      z '.content',
        z '.g-grid',
          z '.title', @model.l.get 'newTradeConfirm.youWant'
          _map receiveItemsWithComponents, ({itemInfo, $item}) ->
            z '.item',
              z $item, {
                countOverlay: itemInfo.count
                sizePx: ITEM_SIZE
              }

          z '.divider'

          z '.title', @model.l.get 'newTradeConfirm.youreOffering'
          _map sendItemsWithComponents, ({itemInfo, $item}) ->
            z '.item',
              z $item, {
                countOverlay: itemInfo.count
                sizePx: ITEM_SIZE
              }

          z '.divider'

          z '.title', @model.l.get 'newTradeConfirm.tradingWith'
          _map toWithComponents, ({userInfo, $avatar}) =>
            z '.user',
              z '.avatar',
                z $avatar, {user: userInfo, bgColor: colors.$grey200}
              z '.name', @model.user.getDisplayName userInfo
