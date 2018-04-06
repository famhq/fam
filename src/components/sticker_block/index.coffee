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
  constructor: (options) ->
    {@model, isLocked, itemInfo, hasCount, hasName, sizePx, @initialItemSize
      hideActions, useRawCount} = options

    isLocked ?= null

    @$sticker = new Sticker {
      @model, isLocked, itemInfo, useRawCount
      sizePx: sizePx
    }

    @state = z.state
      me: @model.user.getMe()
      itemInfo: itemInfo
      hasCount: hasCount
      hasName: hasName
      hideActions: hideActions
      sizePx: sizePx

  update: ({isLocked, itemInfo,}) =>
    @$sticker.update {isLocked, itemInfo}
    @state.set {isLocked, itemInfo}

  getHeight: =>
    {sizePx, hasCount, hasName} = @state.getValue()

    unless sizePx
      return 0

    height = sizePx or @initialItemSize
    if hasCount
      height += 22
    if hasName
      height += 22
    height

  render: ({onclick}) =>
    {me, itemInfo, hasCount, hasName, hideActions, sizePx} = @state.getValue()

    hasCount ?= true
    itemInfo ?= {}
    {item, count, itemLevel} = itemInfo
    itemLevel ?= 1
    item ?= {}

    nextLevelCount = _find(
      config.ITEM_LEVEL_REQUIREMENTS, {level: itemLevel + 1}
    )?.countRequired
    percent = Math.min(100, Math.round(100 * (count / nextLevelCount)))
    # canUpgrade = count >= nextLevelCount and not hideActions
    isOwned = count > 0
    height = @getHeight()

    z '.z-sticker-block', {
      className: z.classKebab {
        # canUpgrade
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

        if hasName
          z '.name',
            item.name


      if hasCount
        z '.count', {
          # className: z.classKebab {canUpgrade}
          # onclick: (e) =>
          #   e?.stopPropagation()
          #   if canUpgrade
          #     @model.userItem.upgradeByItemKey item.key
        },
          z '.bar', {
            style:
              width: "#{percent}%"
          }
          z '.text',
            # if canUpgrade and not hideActions
            #   "#{@model.l.get 'general.upgrade'}
            #   (#{count} / #{nextLevelCount})"
            if nextLevelCount and not hideActions
              "#{count} / #{nextLevelCount}"
            else
              count
