z = require 'zorium'
colors = require '../../colors'
_clone = require 'lodash/clone'
_startCase = require 'lodash/startCase'
_find = require 'lodash/find'

Sticker = require '../sticker'
config = require '../../config'

if window?
  require './index.styl'

PADDING_PX = 0#4

module.exports = class StickerBlock
  constructor: ({@model, isLocked, itemInfo, hasCount, sizePx, hideActions}) ->
    isLocked ?= null

    @$sticker = new Sticker {
      @model, isLocked, itemInfo
      sizePx: if sizePx then sizePx - PADDING_PX * 2 else sizePx
    }

    @state = z.state
      me: @model.user.getMe()
      itemInfo: itemInfo
      hasCount: hasCount
      hideActions: hideActions
      sizePx: sizePx

  render: ({sizePx, onclick}) =>
    sizePxProp = sizePx
    {me, itemInfo, hasCount, hideActions, izePx} = @state.getValue()

    sizePx ?= sizePxProp

    hasCount ?= true
    itemInfo ?= {}
    {item, count, itemLevel} = itemInfo
    itemLevel ?= 1
    item ?= {}

    upgradeReqCount = _find(
      config.ITEM_LEVEL_REQUIREMENTS, {level: itemLevel + 1}
    )?.countRequired
    percent = Math.min(100, Math.round(100 * (count / upgradeReqCount)))
    canUpgrade = count >= upgradeReqCount and not hideActions
    isOwned = count > 0

    height = if hasCount then sizePx + 22 else sizePx

    z '.z-sticker-block', {
      className: z.classKebab {
        canUpgrade
        "is#{_startCase(item.rarity)}": true
        isOwned: isOwned
      }
      onclick: (e) ->
        onclick? e, item
      style:
        width: "#{sizePx}px"
        height: "#{height}px"
    },
      if item?.circulationLimit? and
          item.circulating >= item.circulationLimit
        z '.sold-out'

      z '.sticker',
        z @$sticker, {
          sizePx: if sizePx then sizePx - PADDING_PX * 2 else sizePx
          onclick
        }
        z '.rarity-bar'

      if hasCount
        z '.count', {
          className: z.classKebab {canUpgrade}
          onclick: (e) =>
            e?.stopPropagation()
            if canUpgrade
              @model.userItem.upgradeByItemKey item.key
        },
          z '.bar', {
            style:
              width: "#{percent}%"
          }
          z '.text',
            if canUpgrade and not hideActions
              "#{@model.l.get 'general.upgrade'}
              (#{count} / #{upgradeReqCount})"
            else if upgradeReqCount and not hideActions
              "#{count} / #{upgradeReqCount}"
            else
              count
