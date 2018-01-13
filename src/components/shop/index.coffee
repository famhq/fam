z = require 'zorium'
_isEmpty = require 'lodash/isEmpty'
_map = require 'lodash/map'
_defaults = require 'lodash/defaults'
_orderBy = require 'lodash/orderBy'
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
UiCard = require '../ui_card'
DateService = require '../../services/date'
FormatService = require '../../services/format'
colors = require '../../colors'
config = require '../../config'

ONE_DAY_MS = 24 * 3600 * 1000

if window?
  require './index.styl'

module.exports = class Shop
  constructor: ({@model, @router, gameKey, products, @overlay$, @goToEarnFn}) ->
    @$spinner = new Spinner()

    me = @model.user.getMe()
    products ?= @model.product.getAll()
    @isPurchaseLoading = new RxBehaviorSubject false

    @$infoCard = new UiCard()

    @state = z.state
      me: @model.user.getMe()
      gameKey: gameKey
      isPurchaseLoading: @isPurchaseLoading
      isInfoCardVisible: window? and not localStorage?['hideShopInfo']
      products: products.map (products) =>
        products = _orderBy products, 'cost', 'asc'
        _map products, (product) =>
          {
            $buyButton: new PrimaryButton()
            $fireIcon: new Icon()
            product: product
            onPurchase: (items) =>
              # buying anything removes ads for day
              if product.cost > 0
                @model.ad.hideAds ONE_DAY_MS
              if product.type is 'pack'
                overlay$ = @overlay$.getValue()
                @overlay$.next [overlay$].concat [new OpenPack {
                  @model
                  pack: product
                  items: RxObservable.of items
                  onClose: =>
                    @overlay$.next null
                }]
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
              else if product.key.match(/google_play_10|visa_10/)
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
    {me, products, gameKey, isPurchaseLoading,
      isInfoCardVisible} = @state.getValue()

    z '.z-shop',
      z '.g-grid',
        if isInfoCardVisible
          z '.info-card',
            z @$infoCard,
              $content: @model.l.get 'shop.infoCardText'
              submit:
                text: @model.l.get 'installOverlay.closeButtonText'
                onclick: =>
                  @state.set isInfoCardVisible: false
                  localStorage?['hideShopInfo'] = '1'
        if products and _isEmpty products
          z '.no-products',
            @model.l.get 'shop.empty'
        else if products
          z '.g-cols.no-padding',
            _map products, (options) =>
              {product, $buyButton, $fireIcon,
                onPurchase, onBeforePurchase} = options

              isDisabled = product.isLocked or
                            not me?.fire? or me?.fire < product.cost
              isFree = product.cost is 0
              z '.g-col.g-xs-6.g-md-2', {
                style:
                  backgroundImage: "url(#{product.data?.backgroundImage})"
                  backgroundColor: product.data?.backgroundColor
                onclick: =>
                  ga? 'send', 'event', 'product', 'buy', product.key
                  if isDisabled
                    @goToEarnFn?()
                  else
                    (onBeforePurchase?() or Promise.resolve())
                    .then (data) =>
                      @isPurchaseLoading.next true
                      @model.product.buy _defaults data, {key: product.key}
                    .then onPurchase
                    .then =>
                      @isPurchaseLoading.next false
              },
                z '.info',
                  z '.name', product.name
                  # if product.isLimited
                  #   z '.limited', @model.l.get 'spendFire.limited'
                  if isPurchaseLoading
                    @model.l.get 'general.loading'
                  else
                    z '.cost',
                      z '.amount',
                        if product.isLocked
                        then DateService.formatSeconds \
                              product.lockExpireSeconds
                        else if isFree \
                        then @model.l.get 'general.free'
                        else FormatService.number product.cost
                      z '.icon',
                        z $fireIcon,
                          icon: if product.isLocked \
                                then 'lock-outline'
                                else 'fire'
                          size: '16px'
                          color: colors.$quaternary500
                          isTouchTarget: false
        else
          @$spinner
