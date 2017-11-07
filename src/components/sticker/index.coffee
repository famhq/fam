z = require 'zorium'
colors = require '../../colors'
_clone = require 'lodash/clone'

config = require '../../config'

if window?
  require './index.styl'

MIN_STICKER_SIZE_FOR_LARGE = 50

module.exports = class Sticker
  constructor: ({@model, isLocked, itemInfo, hasCount, sizePx}) ->
    isLocked ?= null

    @state = z.state
      me: @model.user.getMe()
      meItemIds: @model.userItem.getAll()
      isLocked: isLocked
      itemInfo: itemInfo
      hasCount: hasCount
      sizePx: sizePx

  render: ({sizePx, onclick}) =>
    sizePxProp = sizePx
    {me, isLocked, itemInfo, meItemIds, hasCount, sizePx} = @state.getValue()

    sizePx ?= sizePxProp

    hasCount ?= true
    itemInfo ?= {}
    {item, count, level} = itemInfo
    level ?= 1
    item ?= {}
    isLocked ?= not @model.userItem.isOwnedByUserItemsAndItemKey(
      meItemIds, item.key
    )

    filenameParts = [level]
    if sizePx < MIN_STICKER_SIZE_FOR_LARGE
      filenameParts.push 'small'
    else
      filenameParts.push 'large'

    stickerSrc = config.CDN_URL + '/stickers/' +
                "#{item.key}_#{filenameParts.join('_')}.png?1"


    height = if hasCount then sizePx + 20 else sizePx
    imageProps = {
      src: stickerSrc
    }
    if sizePx
      imageProps.width = sizePx
      imageProps.height = sizePx

    z '.z-sticker', {
      className: z.classKebab {isLocked}
      onclick: (e) ->
        onclick? e, item
      style:
        width: "#{sizePx}px"
        height: "#{height}px"
    },
      if item?.circulationLimit? and
          item.circulating >= item.circulationLimit
        z '.sold-out'

      z 'img.sticker', imageProps
      if hasCount
        z '.count', count
