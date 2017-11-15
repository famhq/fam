z = require 'zorium'
_clone = require 'lodash/clone'
_startCase = require 'lodash/startCase'
_find = require 'lodash/find'

Sticker = require '../sticker'
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

FLIP_TIME_MS = 300 # 0.3s

module.exports = class StickerOpen
  constructor: ({@model, isLocked, itemInfo, sizePx, isBack, backKey}) ->
    isLocked ?= null

    @$sticker = new Sticker {
      @model, isLocked, itemInfo, sizePx
    }

    @state = z.state
      me: @model.user.getMe()
      itemInfo: itemInfo
      sizePx: sizePx
      isBack: isBack
      backKey: backKey

  flip: =>
    @state.set isBack: false
    new Promise (resolve) ->
      setTimeout resolve, FLIP_TIME_MS

  render: ({sizePx, onclick}) =>
    sizePxProp = sizePx
    {me, itemInfo, sizePx, isBack, backKey} = @state.getValue()

    sizePx ?= sizePxProp

    itemInfo ?= {}
    {item, count, itemLevel} = itemInfo
    itemLevel ?= 1
    item ?= {}

    color = "$#{config.RARITY_COLORS[item?.rarity]}500"
    if color is '$white500'
      color = '$black'

    backImageUrl = "url(#{config.CDN_URL}/stickers/backs/" +
                   "#{backKey}_back_#{item?.rarity}.png)"

    z '.z-sticker-open', {
      className: z.classKebab {
        isBack
      }
      onclick: (e) ->
        onclick? e, item
      # style:
      #   width: "#{sizePx}px"
      #   height: "#{sizePx}px"
    },
      if item?.circulationLimit? and
          item.circulating >= item.circulationLimit
        z '.sold-out'

      z '.front',
        z '.sticker',
          z @$sticker, {
            sizePx
            onclick
          }
        z '.name', item?.name
        z '.rarity', {
          style:
            color: colors[color]
        },
          item?.rarity

      z '.back',
        style:
          backgroundImage: if backKey then backImageUrl
