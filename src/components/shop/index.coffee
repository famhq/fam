z = require 'zorium'
_isEmpty = require 'lodash/isEmpty'
_map = require 'lodash/map'
_defaults = require 'lodash/defaults'
RxObservable = require('rxjs/Observable').Observable
require 'rxjs/add/operator/map'
require 'rxjs/add/observable/of'

Spinner = require '../spinner'
PrimaryButton = require '../primary_button'
OpenPack = require '../open_pack'
ConfirmPackPurchase = require '../confirm_pack_purchase'
FormatService = require '../../services/format'
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class Shop
  constructor: ({@model, @router, gameKey, products, @overlay$}) ->
    @$spinner = new Spinner()

    me = @model.user.getMe()
    products ?= @model.product.getAll()

    @state = z.state
      me: @model.user.getMe()
      gameKey: gameKey
      products: products.map (products) =>
        _map products, (product) =>
          {
            $buyButton: new PrimaryButton()
            product: product
            onPurchase: (items) =>
              @overlay$.next new OpenPack {
                @model
                items: RxObservable.of items
                onClose: =>
                  @overlay$.next null
              }
            beforePurchase: =>
              @overlay$.next new ConfirmPackPurchase {
                @model, @router, gameKey, @overlay$, pack: product
                onConfirm: =>
                  @model.product.buy
              }
          }

  render: =>
    {me, products, gameKey} = @state.getValue()

    z '.z-shop',
      z '.products',
        if products and _isEmpty products
          'No products found'
        else if products
          _map products, ({product, $buyButton, onPurchase}) =>
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
                    z '.z-spend-fire_buy-button',
                      z '.amount', FormatService.number product.cost
                      z '.icon',
                        z product.$fireIcon,
                          icon: 'fire'
                          color: if isDisabled \
                                 then colors.$quaternary500
                                 else colors.$white
                          isTouchTarget: false
                  isFullWidth: false
                  isDisabled: isDisabled
                  onclick: =>
                    ga? 'send', 'event', 'product', 'buy', product.key
                    (product.beforePurchase?() or Promise.resolve())
                    .then (data) =>
                      @model.product.buy _defaults data, {key: product.key}
                    .then onPurchase

        else
          @$spinner
