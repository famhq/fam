z = require 'zorium'
colors = require '../../colors'
_clone = require 'lodash/clone'
_startCase = require 'lodash/startCase'

config = require '../../config'

if window?
  require './index.styl'

MIN_STICKER_SIZE_FOR_LARGE = 50

module.exports = class Sticker
  constructor: ({@model, isLocked, itemInfo, sizePx}) ->
    isLocked ?= null

    @state = z.state
      me: @model.user.getMe()
      meItemIds: @model.userItem.getAll()
      isLocked: isLocked
      itemInfo: itemInfo
      sizePx: sizePx

  render: ({sizePx, onclick, hasRarityBar}) =>
    sizePxProp = sizePx
    {me, isLocked, itemInfo, meItemIds, sizePx} = @state.getValue()

    sizePx ?= sizePxProp

    itemInfo ?= {}
    {item, count, itemLevel} = itemInfo
    itemLevel ?= 1
    item ?= {}
    isLocked ?= not @model.userItem.isOwnedByUserItemsAndItemKey(
      meItemIds, item.key
    )

    filenameParts = [itemLevel]
    if sizePx < MIN_STICKER_SIZE_FOR_LARGE
      filenameParts.push 'small'
    else
      filenameParts.push 'large'

    stickerSrc = config.CDN_URL + '/stickers/' +
                "#{item.key}_#{filenameParts.join('_')}.png?1"


    imageProps = {
      src: stickerSrc
    }
    if sizePx
      imageProps.width = sizePx
      imageProps.height = sizePx

    z '.z-sticker', {
      className: z.classKebab {
        isLocked
        "is#{_startCase(item.rarity)}": true
      }
      onclick: (e) ->
        onclick? e, item
      style:
        width: "#{sizePx}px"
        height: "#{sizePx}px"
    },
      z 'img.sticker', imageProps
      if hasRarityBar
        z '.rarity-bar'
