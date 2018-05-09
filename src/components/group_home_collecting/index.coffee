z = require 'zorium'
_map = require 'lodash/map'
_filter = require 'lodash/filter'
_isEmpty = require 'lodash/isEmpty'
RxObservable = require('rxjs/Observable').Observable
require 'rxjs/add/observable/combineLatest'

Base = require '../base'
Spinner = require '../spinner'
UiCard = require '../ui_card'
FlatButton = require '../flat_button'
Icon = require '../icon'
CurrencyIcon = require '../currency_icon'
FormatService = require '../../services/format'
config = require '../../config'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class GroupHomeChat
  constructor: ({@model, @router, group, player, @overlay$}) ->
    me = @model.user.getMe()
    itemKey = group.map (group) ->
      group.currency?.itemKey

    @$spinner = new Spinner()
    @$uiCard = new UiCard()
    @$currencyIcon = new CurrencyIcon {itemKey}

    @$collectionButton = new FlatButton()
    @$tradesButton = new FlatButton()

    tradesAndMe = RxObservable.combineLatest(
      @model.trade.getAll()
      me
      (vals...) -> vals
    )

    @state = z.state {
      group
      currencyItem: group.switchMap (group) =>
        itemKey = group.currency?.itemKey
        if itemKey
          @model.userItem.getByItemKey itemKey
        else
          RxObservable.of null
      pendingTrades: tradesAndMe
      .map ([trades, me]) ->
        _filter trades, (trade) ->
          isExpired = not trade.expireTime or
            Date.parse(trade.expireTime) < @model.time.getServerTime()
          trade.fromId isnt me.id and trade.status is 'pending' and
              not isExpired
      freeProducts: group.switchMap (group) =>
        @model.product.getAllByGroupId group.id
        .map (products) ->
          _filter products, ({cost, isLocked}) ->
            cost is 0 and not isLocked
    }

  render: =>
    {group, currencyItem, freeProducts, pendingTrades} = @state.getValue()

    z '.z-group-home-collecting',
      z @$uiCard,
        $title: @model.l.get 'general.collection'
        $content:
          z '.z-group-home_ui-card',
            z '.currency-amount',
              FormatService.number currencyItem?.count or 0
              z '.icon',
                z @$currencyIcon, {size: '20px'}
            unless _isEmpty freeProducts
              product = freeProducts[0]
              z '.row',
                z '.product',
                  style:
                    backgroundImage: "url(#{product.data?.backgroundImage})"

                @model.l.get 'groupHomeCollecting.freeProducts'
                z '.button',
                  z @$collectionButton,
                    text: @model.l.get 'general.shop'
                    onclick: =>
                      @model.group.goPath group, 'groupCollectionWithTab', {
                        @router
                        replacements: {tab: 'shop'}
                      }

            z '.row',
              if _isEmpty pendingTrades
                @model.l.get 'groupHomeCollecting.noTrades'
              else
                @model.l.get 'groupHomeCollecting.trades'
              z '.button',
                z @$tradesButton,
                  text: @model.l.get 'tradesPage.title'
                  onclick: =>
                    @model.group.goPath group, 'trades', {@router}
