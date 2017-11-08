z = require 'zorium'
colors = require '../../colors'
_clone = require 'lodash/clone'
_startCase = require 'lodash/startCase'
_find = require 'lodash/find'

Sticker = require '../sticker'
config = require '../../config'

if window?
  require './index.styl'

PADDING_PX = 4

module.exports = class StickerBlock
  constructor: ({@model, isLocked, itemInfo, hasCount, sizePx}) ->
    isLocked ?= null

    @$sticker = new Sticker {
      @model, isLocked, itemInfo
      sizePx: if sizePx then sizePx - PADDING_PX * 2 else sizePx
    }

    @state = z.state
      me: @model.user.getMe()
      itemInfo: itemInfo
      hasCount: hasCount
      sizePx: sizePx

  render: ({sizePx, onclick}) =>
    sizePxProp = sizePx
    {me, itemInfo, hasCount, sizePx} = @state.getValue()

    sizePx ?= sizePxProp

    hasCount ?= true
    itemInfo ?= {}
    {item, count, itemLevel} = itemInfo
    itemLevel ?= 1
    item ?= {}

    upgradeReqCount = _find(
      config.LEVEL_REQUIREMENTS, {level: itemLevel + 1}
    )?.countRequired
    percent = Math.min(100, Math.round(100 * (count / upgradeReqCount)))
    canUpgrade = count >= upgradeReqCount

    height = if hasCount then sizePx + 24 else sizePx

    z '.z-sticker-block', {
      className: z.classKebab {
        canUpgrade
        "is#{_startCase(item.rarity)}": true
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

      if hasCount
        z '.count', {
          onclick: =>
            @model.userItem.upgradeByItemKey item.key
        },
          z '.bar', {
            style:
              width: "#{percent}%"
          }
          z '.text',
            if canUpgrade
              "Upgrade (#{count} / #{upgradeReqCount})"
            else if upgradeReqCount
              "#{count} / #{upgradeReqCount}"
            else
              count
