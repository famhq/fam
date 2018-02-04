z = require 'zorium'
colors = require '../../colors'
_clone = require 'lodash/clone'
_startCase = require 'lodash/startCase'
_find = require 'lodash/find'

Item = require '../item'
config = require '../../config'

if window?
  require './index.styl'

PADDING_PX = 0#4

module.exports = class ItemBlock
  constructor: ({@model, isLocked, itemInfo, hasCount, sizePx, group}) ->
    isLocked ?= null

    @$item = new Item {
      @model, isLocked, itemInfo
      sizePx: if sizePx then sizePx - PADDING_PX * 2 else sizePx
    }

    @state = z.state
      me: @model.user.getMe()
      itemInfo: itemInfo
      hasCount: hasCount
      group: group
      sizePx: sizePx

  render: ({sizePx, onclick}) =>
    sizePxProp = sizePx
    {me, itemInfo, hasCount, sizePx, group} = @state.getValue()

    sizePx ?= sizePxProp

    hasCount ?= true
    itemInfo ?= {}
    {item, count, itemLevel} = itemInfo
    itemLevel ?= 1
    item ?= {}

    isConsumable = item.type in ['consumable', 'scratch']
    canConsume = isConsumable and count > 0
    isOwned = count > 0
    height = if hasCount then sizePx + 22 else sizePx

    z '.z-item-block', {
      className: z.classKebab {
        "is#{_startCase(item.rarity)}": true
        isOwned: isOwned
      }
      onclick: (e) ->
        onclick? e, item
      style:
        width: "#{sizePx}px"
        height: "#{height}px"
    },
      z '.item',
        z @$item, {
          sizePx: if sizePx then sizePx - PADDING_PX * 2 else sizePx
          onclick
        }

        if canConsume
          z '.use',
            @model.l.get 'collection.use'

      if hasCount
        z '.count', {
          className: z.classKebab {canConsume}
        },
          count
