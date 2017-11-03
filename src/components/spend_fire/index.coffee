z = require 'zorium'
_map = require 'lodash/map'
_defaults = require 'lodash/defaults'
_filter = require 'lodash/filter'

PrimaryButton = require '../primary_button'
Icon = require '../icon'
BuyGiftCardDialog = require '../buy_gift_card_dialog'
FormatService = require '../../services/format'
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

ONE_DAY_MS = 24 * 3600 * 1000

# TODO: migrate to shop
module.exports = class SpendFire
  constructor: ({@model, @router, @overlay$}) ->
    me = @model.user.getMe()
    @state = z.state
      me: me
      items: me.map (me) =>
        country = me?.country?.toLowerCase()
        _filter [
          {
            id: 'noAdsForDay'
            name: @model.l.get 'noAdsForDay.title', {file: 'products'}
            cost: 50
            $fireIcon: new Icon()
            $buyButton: new PrimaryButton()
            onPurchase: =>
              @model.ad.hideAds ONE_DAY_MS
          }
          if country in ['mx', 'us', 'br', 'kr', 'jp']
            {
              id: 'googlePlay10'
              # name: @model.l.get 'googlePlay10.title', {file: 'products'}
              name: if country is 'us' \
                    then '$10 Google Play gift card'
                    else if country is 'mx'
                    then '200 MXN Google Play tarjeta de regalo'
                    else if country is 'br'
                    then '30 BRL Google Play cartão presente'
                    else if country is 'kr'
                    then '10,000 WON Google Play 기프트 카드'
              cost: 15000
              isLimited: true
              $fireIcon: new Icon()
              $buyButton: new PrimaryButton()
              beforePurchase: =>
                new Promise (resolve, reject) =>
                  $buyGiftCardDialog = new BuyGiftCardDialog {
                    @model, @router, @overlay$
                  }
                  @overlay$.next z $buyGiftCardDialog, {
                    onSubmit: resolve, onLeave: reject
                  }
              onPurchase: ->
                null
            }
          {
            id: 'visa10'
            # name: @model.l.get 'googlePlay10.title', {file: 'products'}
            name: '$10 Visa gift card'
            cost: 15000
            isLimited: true
            $fireIcon: new Icon()
            $buyButton: new PrimaryButton()
            beforePurchase: =>
              new Promise (resolve, reject) =>
                $buyGiftCardDialog = new BuyGiftCardDialog {
                  @model, @router, @overlay$
                }
                @overlay$.next z $buyGiftCardDialog, {
                  onSubmit: resolve, onLeave: reject
                }
            onPurchase: ->
              null
          }
        ]

  render: =>
    {me, items} = @state.getValue()

    z '.z-spend-fire',
      z 'p', @model.l.get 'spendFire.description1'
      z '.items',
        _map items, (item) =>
          isDisabled = not me?.fire or me?.fire < item.cost
          z '.item',
            z '.info',
              z '.name', item.name
              if item.isLimited
                z '.limited', @model.l.get 'spendFire.limited'
            z '.buy',
              z item.$buyButton,
                text:
                  z '.z-spend-fire_buy-button',
                    z '.amount', FormatService.number item.cost
                    z '.icon',
                      z item.$fireIcon,
                        icon: 'fire'
                        color: if isDisabled \
                               then colors.$quaternary500
                               else colors.$white
                        isTouchTarget: false
                isFullWidth: false
                isDisabled: isDisabled
                onclick: =>
                  ga? 'send', 'event', 'item', 'buy', item.id
                  (item.beforePurchase?() or Promise.resolve())
                  .then (data) =>
                    @model.product.buy _defaults data, {key: item.id}
                  .then item.onPurchase
