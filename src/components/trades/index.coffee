z = require 'zorium'
_map = require 'lodash/map'
_defaults = require 'lodash/defaults'
_take = require 'lodash/take'
_isEmpty = require 'lodash/isEmpty'
Environment = require 'clay-environment'

Icon = require '../icon'
Item = require '../item'
Sticker = require '../sticker'
Spinner = require '../spinner'
FormatService = require '../../services/format'
DateService = require '../../services/date'
ItemService = require '../../services/item'
colors = require '../../colors'

if window?
  require './index.styl'


# TODO: put these in a vars file that stylus and coffeescript uses
PAGE_PADDING = 16
ICON_SIZE = 40
ICON_MARGIN = 16
CARD_MARGIN = 8
FADE_WIDTH = 8
MAX_TRADE_CARDS_VISIBLE = 4

module.exports = class Trades
  constructor: ({@model, @router, trades}) ->
    @$swapIcon = new Icon()
    @$spinner = new Spinner()

    @state = z.state
      me: @model.user.getMe()
      trades: trades.map (trades) =>
        _map trades, (trade) =>
          sendItems = trade.sendItems
          sendItemCount = Math.min(
            sendItems?.length
            MAX_TRADE_CARDS_VISIBLE
          )

          receiveItems = trade.receiveItems
          receiveItemCount = Math.min(
            receiveItems?.length
            MAX_TRADE_CARDS_VISIBLE
          )
          {
            tradeInfo: _defaults {
              sendItemsWithComponents: _map(
                _take(sendItems, sendItemCount), (itemInfo) =>
                  ItemClass = if itemInfo.item.type is 'sticker' \
                              then Sticker
                              else Item
                  {
                    info: itemInfo
                    $item: new ItemClass {@model, itemInfo}
                  }
              )
              sendItemCount: sendItems?.length

              receiveItemsWithComponents: _map(
                _take(receiveItems, receiveItemCount), (itemInfo) =>
                  ItemClass = if itemInfo.item.type is 'sticker' \
                              then Sticker
                              else Item
                  {
                    info: itemInfo
                    $item: new ItemClass {@model, itemInfo}
                  }
              )
              receiveItemCount: receiveItems?.length
            }, trade
            $clockIcon: new Icon()
            $deleteIcon: new Icon()
            $swapIcon: new Icon()
          }

  render: ({$emptyStateTitle}) =>
    {me, trades} = @state.getValue()

    windowWidth = window?.innerWidth or 360
    itemsDivWidth = windowWidth - PAGE_PADDING * 2 - ICON_SIZE - ICON_MARGIN -
                    FADE_WIDTH
    cardWidth = (itemsDivWidth / MAX_TRADE_CARDS_VISIBLE) - CARD_MARGIN
    cardWidth = Math.min cardWidth, 120

    z '.z-trades',
      if not trades
        z @$spinner
      else if _isEmpty trades
        z '.no-trades',
          z '.icon',
            z @$swapIcon,
              icon: 'trade-circle'
              color: colors.$tertiary900Text
              size: '80px'
              isTouchTarget: false

          z '.title', $emptyStateTitle
          z '.description',
            z 'div', @model.l.get 'trades.empty'
      else
        z '.g-grid',
          z '.trades',
            _map trades, (trade) =>
              {tradeInfo, $deleteIcon, $clockIcon, $swapIcon} = trade
              isComplete = tradeInfo.status is 'approved'
              isTradeRecipient = me and tradeInfo and
                                  me.id isnt tradeInfo.fromId
              otherName = if isTradeRecipient \
                      then tradeInfo.from?.username or @model.user.DEFAULT_NAME
                      else tradeInfo.to?.username or @model.user.DEFAULT_NAME
              tradeInfo.expireTime ?= 0
              secondsUntilExpire = (
                Date.parse(tradeInfo.expireTime) - @model.time.getServerTime()
              ) / 1000
              isExpired = not isComplete and secondsUntilExpire <= 0
              isPending = not isExpired and tradeInfo.status is 'pending'
              isDeclined = tradeInfo.status is 'declined'
              sendItemCount = tradeInfo.sendItemCount
              receiveItemCount = tradeInfo.receiveItemCount

              $tradeSend =
                z '.sending',
                  _map tradeInfo.sendItemsWithComponents, ({info, $item}) ->
                    z '.item',
                      z $item, {
                        info: info
                        countOverlay: info.count
                        sizePx: cardWidth
                        hasRarityBar: true
                      }
                  if sendItemCount >= MAX_TRADE_CARDS_VISIBLE
                    z '.fade-out',
                      if sendItemCount > MAX_TRADE_CARDS_VISIBLE
                        "+#{sendItemCount - MAX_TRADE_CARDS_VISIBLE}"

              $tradeReceive =
                z '.receiving',
                  _map tradeInfo.receiveItemsWithComponents, ({info, $item}) ->
                    z '.item',
                      z $item, {
                        info: info
                        countOverlay: info.count
                        sizePx: cardWidth
                        hasRarityBar: true
                      }
                  if receiveItemCount >= MAX_TRADE_CARDS_VISIBLE
                    z '.fade-out',
                      if receiveItemCount > MAX_TRADE_CARDS_VISIBLE
                        "+#{receiveItemCount - MAX_TRADE_CARDS_VISIBLE}"

              z '.trade', {
                className: z.classKebab {
                  isPending
                  isComplete
                  isExpired
                  isDeclined
                }
                onclick: =>
                  @router.go 'trade', {id: tradeInfo.id}
              },
                z '.icon',
                  z $clockIcon,
                    icon: if isDeclined \
                          then 'close'
                          else if isComplete
                          then 'check'
                          else 'pending'
                    color: colors.$primary500Text
                    isTouchTarget: false
                z '.details',
                  z '.title', if isComplete \
                              then "#{otherName} accepted"
                              else if isDeclined
                              then 'Declined trade'
                              else 'Pending trade'
                  z '.description',
                    z '.time', DateService.fromNow(tradeInfo.time)
                    if not isComplete
                      z '.expires',
                        if isExpired
                          @model.l.get 'trades.expired'
                        else
                          @model.l.get 'trades.expiresIn', {
                            replacements:
                              time: FormatService.countdown secondsUntilExpire
                          }
                  z '.items',
                    if isTradeRecipient then $tradeSend else $tradeReceive
                    z '.swap-icon',
                      z $swapIcon,
                        icon: 'trade'
                        color: colors.$primary500
                        isTouchTarget: false
                    if isTradeRecipient then $tradeReceive else $tradeSend

                  z '.divider'

                if tradeInfo.fromId is me?.id and not isComplete
                  z '.delete',
                    z $deleteIcon,
                      icon: 'close'
                      color: colors.$tertiary900
                      isAlignedTop: true
                      onclick: (e) =>
                        e.stopPropagation()
                        @model.trade.deleteById tradeInfo.id
