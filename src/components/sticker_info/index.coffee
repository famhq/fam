z = require 'zorium'
_pick = require 'lodash/pick'
_defaults = require 'lodash/defaults'
_map = require 'lodash/map'
_range = require 'lodash/range'
_find = require 'lodash/find'

AppBar = require '../app_bar'
ButtonBack = require '../button_back'
Sticker = require '../sticker'
Icon = require '../icon'
FormatService = require '../../services/format'
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

LEVELS = 3

module.exports = class StickerInfo
  constructor: ({@model, @portal, @router, infoStreams, onClose}) ->
    itemInfo = infoStreams.switch()


    @$appBar = new AppBar {@model, @router}
    @$backButton = new ButtonBack {@router, @model}
    @$globeIcon = new Icon()
    @$collectionIcon = new Icon()
    @$addStickerIcon = new Icon()
    @$closeIcon = new Icon()
    @$stickers = _map _range(LEVELS), (i) =>
      level = i + 1
      {
        level: level
        $el: new Sticker {
          @model
          itemInfo: itemInfo.map (info) ->
            _defaults {itemLevel: level}, info
        }
      }

    @$nextIcon1 = new Icon()
    @$nextIcon2 = new Icon()

    @state = z.state
      me: @model.user.getMe()
      itemInfo: itemInfo
      onClose: onClose

  render: =>
    {me, itemInfo, onClose} = @state.getValue()

    stickerSize = 80

    itemInfo ?= {}
    sticker = itemInfo.item

    z '.z-sticker-info',
      z @$appBar,
        $topLeftButton: z @$backButton, {
          color: colors.$primary500
          onclick: ->
            onClose?()
        }
        $topRightButton: @$menuFireAmount
        title: sticker?.name

        # z '.cp',
        #   z '.icon',
        #     z @$cpIcon,
        #       icon: 'cp'
        #       isTouchTarget: false
        #       color: colors.$amber500
        #   FormatService.number @model.item.getCp info

        # FIXME FIXME: get rid of arrows. store levels as array in constructor,
        # map over them to look like news items (icon left, content right)

      z '.g-grid',
        z '.g-cols',
        _map @$stickers, ({level, $el}) =>
          requirement = _find config.ITEM_LEVEL_REQUIREMENTS, {level}
          z '.g-col.g-xs-12.g-md-6',
            z '.sticker',
              z $el, {
                sizePx: stickerSize
              }
            z '.info',
              z '.level', "Level #{level}"
              @model.l.get 'stickerInfo.levelUpRequirement', {
                replacements:
                  countRequired: requirement?.countRequired
              }

        # z '.info',
        #   z '.name',
        #     sticker?.name
        #   z '.stats',
        #     z '.circulating',
        #       z '.icon',
        #         z @$globeIcon2,
        #           icon: 'globe'
        #           isTouchTarget: false
        #           size: '16px'
        #           color: colors.$tertiary500
        #       z '.count', FormatService.number sticker?.circulating
        #     z '.owned',
        #       z '.icon',
        #         z @$collectionIcon,
        #           icon: 'collection'
        #           isTouchTarget: false
        #           size: '16px'
        #           color: colors.$tertiary500
        #       z '.count', FormatService.number itemInfo.count or 0


      # z '.actions',
      #   z '.button', {
      #     onclick: ->
      #       onClose?()
      #   },
      #     z '.icon',
      #       z @$closeIcon,
      #         icon: 'close'
      #         color: colors.$tertiary900
      #         isTouchTarget: false
      #     'Cancel'
