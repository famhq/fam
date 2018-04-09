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
  constructor: (options) ->
    {@model, isLocked, itemInfo, hasCount, sizePx, hasName
      hideActions, group} = options

    isLocked ?= null

    @$item = new Item {
      @model, isLocked, itemInfo
      sizePx: sizePx
    }

    @state = z.state
      me: @model.user.getMe()
      itemInfo: itemInfo
      hasCount: hasCount
      hasName: hasName
      group: group
      hideActions: hideActions
      sizePx: sizePx

  update: ({isLocked, itemInfo}) =>
    @$item.update {isLocked, itemInfo}
    @state.set {isLocked, itemInfo}


  getHeight: ->
    {sizePx, hasCount, hasName} = @state.getValue()

    unless sizePx
      return 0

    height = sizePx
    if hasCount
      height += 22
    if hasName
      height += 22
    height

  render: ({onclick}) =>
    {me, itemInfo, hasCount, hasName, sizePx,
      hideActions, group} = @state.getValue()

    hasCount ?= true
    itemInfo ?= {}
    {item, count, itemLevel} = itemInfo
    itemLevel ?= 1
    item ?= {}

    isConsumable = item.type in ['consumable', 'chest']
    canConsume = isConsumable and count > 0 and not hideActions
    isOwned = count > 0
    height = @getHeight()

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

        if canConsume and not hideActions
          z '.use',
            @model.l.get 'collection.open'

        if hasName
          z '.name',
            item.name

      if hasCount
        z '.count', {
          className: z.classKebab {canConsume}
        },
          count
