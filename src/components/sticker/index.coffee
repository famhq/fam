z = require 'zorium'
colors = require '../../colors'
_clone = require 'lodash/clone'

config = require '../../config'

if window?
  require './index.styl'

MIN_STICKER_SIZE_FOR_LARGE = 50

module.exports = class Sticker
  constructor: ({@model, isLocked, itemInfo}) ->
    isLocked ?= null

    @state = z.state
      me: @model.user.getMe()
      meItemIds: @model.userItem.getAll()
      isLocked: isLocked
      itemInfo: itemInfo

  render: ({size, onclick}) =>
    {me, isLocked, itemInfo, meItemIds} = @state.getValue()

    itemInfo ?= {}
    {item, count} = itemInfo
    item ?= {}
    isLocked ?= not @model.userItem.isOwnedByUserItemsAndItemKey(
      meItemIds, item.key
    )

    filenameParts = []
    if size < MIN_STICKER_SIZE_FOR_LARGE
      filenameParts.push 'small'
    else
      filenameParts.push 'large'

    stickerSrc = config.CDN_URL + '/stickers/' +
                "#{item.key}_#{filenameParts.join('_')}.png"


    z '.z-sticker', {
      className: z.classKebab {isLocked}
      onclick: ->
        onclick? item
      style:
        width: "#{size}px"
        height: "#{size}px"
    },
      if item?.circulationLimit? and
          item.circulating >= item.circulationLimit
        z '.sold-out'

      z 'img.sticker', {
        src: stickerSrc
      }
