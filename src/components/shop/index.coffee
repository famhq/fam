z = require 'zorium'
_isEmpty = require 'lodash/isEmpty'
_map = require 'lodash/map'
_defaults = require 'lodash/defaults'
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject
RxObservable = require('rxjs/Observable').Observable
require 'rxjs/add/operator/map'
require 'rxjs/add/observable/of'

Spinner = require '../spinner'
Icon = require '../icon'
PrimaryButton = require '../primary_button'
BuyGiftCardDialog = require '../buy_gift_card_dialog'
OpenPack = require '../open_pack'
ConfirmPackPurchase = require '../confirm_pack_purchase'
FormatService = require '../../services/format'
colors = require '../../colors'
config = require '../../config'

ONE_DAY_MS = 24 * 3600 * 1000

if window?
  require './index.styl'

module.exports = class Shop
  constructor: ({@model, @router, gameKey, products, @overlay$}) ->
    @$spinner = new Spinner()

    me = @model.user.getMe()
    products ?= @model.product.getAll()
    @isPurchaseLoading = new RxBehaviorSubject false

    @state = z.state
      me: @model.user.getMe()
      gameKey: gameKey
      isPurchaseLoading: @isPurchaseLoading
      products: products.map (products) =>
        _map products, (product) =>
          {
            $buyButton: new PrimaryButton()
            $fireIcon: new Icon()
            product: product
            onPurchase: (items) =>
              if product.type is 'pack'
                overlay$ = @overlay$.getValue()
                @overlay$.next [overlay$].concat [new OpenPack {
                  @model
                  items: RxObservable.of items
                  onClose: =>
                    @overlay$.next null
                }]
              else if product.key is 'no_ads_for_day'
                @model.ad.hideAds ONE_DAY_MS
              else
                Promise.resolve()

            onBeforePurchase: =>
              if product.type is 'pack'
                new Promise (resolve, reject) =>
                 # TODO: groupid
                  @overlay$.next new ConfirmPackPurchase {
                    @model, @router, gameKey, @overlay$,
                    @isPurchaseLoading, pack: product
                    onConfirm: resolve, onCancel: =>
                      @overlay$.next null
                      reject()
                  }
              else if product.key in ['google_play_10', 'visa_10']
                new Promise (resolve, reject) =>
                  $buyGiftCardDialog = new BuyGiftCardDialog {
                    @model, @router, @overlay$
                  }
                  @overlay$.next z $buyGiftCardDialog, {
                    onSubmit: resolve, onLeave: reject
                  }
              else
                Promise.resolve()
          }

  render: =>
    {me, products, gameKey, isPurchaseLoading} = @state.getValue()

    z '.z-shop',
      z '.g-grid',
        z '.products',
          if products and _isEmpty products
            @model.l.get 'shop.empty'
          else if products
            _map products, (options) =>
              {product, $buyButton, $fireIcon,
                onPurchase, onBeforePurchase} = options

              isDisabled = not me?.fire or me?.fire < product.cost
              z '.product',
                z '.info',
                  z '.name', @model.l.get "#{product.key}.title", {
                    file: 'products'
                  }
                  if product.isLimited
                    z '.limited', @model.l.get 'spendFire.limited'
                z '.buy',
                  z $buyButton,
                    text:
                      if isPurchaseLoading
                        @model.l.get 'general.loading'
                      else
                        z '.z-spend-fire_buy-button',
                          z '.amount', FormatService.number product.cost
                          z '.icon',
                            z $fireIcon,
                              icon: 'fire'
                              size: '20px'
                              color: if isDisabled \
                                     then colors.$quaternary500
                                     else colors.$white
                              isTouchTarget: false
                    isFullWidth: false
                    isDisabled: isDisabled
                    onclick: =>
                      ga? 'send', 'event', 'product', 'buy', product.key
                      (onBeforePurchase?() or Promise.resolve())
                      .then (data) =>
                        @isPurchaseLoading.next true
                        @model.product.buy _defaults data, {key: product.key}
                      .then onPurchase
                      .then =>
                        @isPurchaseLoading.next false

          else
            @$spinner
