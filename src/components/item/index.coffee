z = require 'zorium'
colors = require '../../colors'
_clone = require 'lodash/clone'
_startCase = require 'lodash/startCase'

config = require '../../config'

if window?
  require './index.styl'

MIN_ITEM_SIZE_FOR_LARGE = 50

module.exports = class Item
  constructor: ({@model, isLocked, itemInfo, sizePx}) ->
    isLocked ?= null

    @state = z.state
      me: @model.user.getMe()
      meUserItems: @model.userItem.getAll()
      isLocked: isLocked
      itemInfo: itemInfo
      sizePx: sizePx

  update: ({isLocked, itemInfo}) =>
    @state.set {isLocked, itemInfo}

  render: ({sizePx, onclick, countOverlay}) =>
    sizePxProp = sizePx
    {me, isLocked, itemInfo, meUserItems, sizePx} = @state.getValue()

    sizePx ?= sizePxProp

    itemInfo ?= {}
    {item, count, itemLevel} = itemInfo
    itemLevel ?= 1
    item ?= {}
    isLocked ?= not @model.userItem.isOwnedByUserItemsAndItemKey(
      meUserItems, item.key
    )

    filenameParts = ['large']

    itemSrc = config.CDN_URL + '/items/' +
                "#{item.key}_#{filenameParts.join('_')}.png?2"


    imageProps = {
      src: itemSrc
    }
    if sizePx
      imageProps.width = sizePx
      imageProps.height = sizePx

    z '.z-item', {
      className: z.classKebab {isLocked}
      onclick: (e) ->
        onclick? e, item
      style:
        width: "#{sizePx}px"
        height: "#{sizePx}px"
    },
      z 'img.item', imageProps
      if countOverlay
        z '.count-overlay', countOverlay
