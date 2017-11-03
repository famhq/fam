z = require 'zorium'
colors = require '../../colors'
_clone = require 'lodash/clone'

config = require '../../config'

if window?
  require './index.styl'

MIN_STICKER_SIZE_FOR_LARGE = 50

module.exports = class Sticker
  constructor: ({@model, isLocked, item}) ->
    isLocked ?= null

    @state = z.state
      me: @model.user.getMe()
      isLocked: isLocked
      item: item

  render: ({size, onclick}) =>
    {me, isLocked, item} = @state.getValue()

    item ?= {}
    count = item.count
    isLocked ?= not @model.user.ownsItem me, item.id

    filenameParts = []
    if size < MIN_STICKER_SIZE_FOR_LARGE
      filenameParts.push 'small'
    else
      filenameParts.push 'large'
    console.log 'item', item
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
