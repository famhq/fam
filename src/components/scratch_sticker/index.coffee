z = require 'zorium'
_isEmpty = require 'lodash/isEmpty'
_map = require 'lodash/map'
_find = require 'lodash/find'
_sum = require 'lodash/sum'
_startCase = require 'lodash/startCase'
_snakeCase = require 'lodash/snakeCase'

FormatService = require '../../services/format'
AppBar = require '../app_bar'
PrimaryButton = require '../primary_button'
ButtonBack = require '../button_back'
# ScratchStickerCanvas = require '../scratch_sticker_canvas'
ScratchieWidget = require '../scratchie_widget'
Sticker = require '../sticker'
Icon = require '../icon'
config = require '../../config'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class ScratchSticker
  constructor: (options) ->
    {@model, @router, infoStreams, @overlay$, group} = options

    @itemInfo = infoStreams.switch()
    topImageSrc = @itemInfo.map (itemInfo) ->
      item = itemInfo?.item
      filenameParts = ['large']
      config.CDN_URL + '/items/' +
                  "#{item.key}_#{filenameParts.join('_')}.png?1"

    @$appBar = new AppBar {@model, @router}
    @$backButton = new ButtonBack {@router, @model}
    # @$scratchStickerCanvas = new ScratchStickerCanvas {
    #   topImageSrc: itemInfo.map (itemInfo) ->
    # }
    @$scratchie = new ScratchieWidget {
      topImageSrc
      @model
      onStart: =>
        @state.set hasStarted: true
    }
    @$fireIcon = new Icon()
    @$actionButton = new PrimaryButton()

    @me = @model.user.getMe()

    @state = z.state
      me: @me
      isLoading: false
      info: @itemInfo
      userItems: @model.userItem.getAll()
      group: group
      hasStarted: false
      $scratchedSticker: null

  beforeUnmount: =>
    @state.set $scratchedSticker: null, hasStarted: false

  render: =>
    {me, info, userItems, isLoading, group, hasStarted,
      $scratchedSticker, topImageSrc} = @state.getValue()

    item = info?.item
    hasScratch = info?.count > 0
    coinRequired = item?.data?.coinRequired
    coinUserItem = coinRequired and _find userItems, {itemKey: coinRequired}
    hasCoin = coinUserItem?.count > 0
    hasScratchedItem = Boolean $scratchedSticker

    z '.z-scratch-sticker',
      z @$appBar,
        $topLeftButton: z @$backButton, {
          color: colors.$header500Icon
          onclick: =>
            @overlay$.next null
        }
        title: info?.name
      z '.content',
        z '.g-grid',
          z '.sticker', {
            className: z.classKebab {hasScratchedItem, hasStarted}
          },
            z '.touch-to-scratch',
              @model.l.get 'scratchieWidget.touchToScratch'
            z @$scratchie,
              $content:
                if $scratchedSticker
                  z $scratchedSticker, {hasRarityBar: true}
          z '.info',
            z '.odds',
              _map item?.data?.odds, ({rarity, odds}) ->
                z '.odd',
                  z '.rarity', _startCase rarity
                  z '.odds', FormatService.percentage odds

          z '.action',
            if hasCoin and hasScratch and not hasScratchedItem
              z @$actionButton,
                $content: if isLoading \
                          then @model.l.get 'general.loading'
                          else "#{@model.l.get 'scratchSticker.useCoin'} " + \
                                "(#{coinUserItem.count})"
                onclick: =>
                  @model.userItem.scratchByItemKey item.key, {groupId: group.id}
                  .then (item) =>
                    @state.set
                      $scratchedSticker: new Sticker {
                        @model
                        itemInfo: {item}
                      }
            else if hasScratchedItem
              z @$actionButton,
                $content: @model.l.get 'general.done'
                onclick: =>
                  @overlay$.next null
            else if hasScratch
              [
                z '.text', @model.l.get 'scratchSticker.needCoins'
                z @$actionButton,
                  $content: @model.l.get 'general.done'
                  onclick: =>
                    @overlay$.next null
              ]
            else
              [
                z '.text', @model.l.get 'scratchSticker.needScratch'
                z @$actionButton,
                  $content: @model.l.get 'general.done'
                  onclick: =>
                    @overlay$.next null
              ]
