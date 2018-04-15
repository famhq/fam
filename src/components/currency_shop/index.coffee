z = require 'zorium'
_map = require 'lodash/map'
_clone = require 'lodash/clone'
RxObservable = require('rxjs/Observable').Observable
RxReplaySubject = require('rxjs/ReplaySubject').ReplaySubject
require 'rxjs/add/observable/of'

Icon = require '../icon'
Spinner = require '../spinner'
PrimaryButton = require '../primary_button'
FormatService = require '../../services/format'
Environment = require '../../services/environment'
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class CurrencyShop
  constructor: ({@model, products, @selectedProduct}) ->
    @$spinner = new Spinner()
    @$newIcon = new Icon()

    @isImpressionSent = false

    @baseProducts = products.map (products) =>
      products = _map products, (product, i) =>
        unless @isImpressionSent
          position = i + 1
          ga 'ec:addImpression', {
            'id': product.productId
            'name': product.name
            'category': 'IAP'
            'list': 'shopv1'
            'position': position
          }
          ga 'send', 'event', 'shop', product.productId, 'impression'

        return {
          $buyButton: new PrimaryButton()
          $currencyIcon: new Icon()
          isLoading: false
          productInfo: product
        }
      @isImpressionSent = true
      return products

    @productsStream = new RxReplaySubject 1
    @productsStream.next @baseProducts

    @state = z.state
      me: @model.user.getMe()
      products: @productsStream.switch()
      platform: Environment.getPlatform {gameKey: config.GAME_KEY}

  beforeUnmount: =>
    @isImpressionSent = false

  buyProduct: (product, i) =>
    {platform, products} = @state.getValue()

    ga 'ec:addProduct', {
      'id': product.productId
      'name': product.name
      'category': 'iap'
    }
    ga 'ec:setAction', 'detail'
    ga 'send', 'event', 'shop', product.productId, 'click'

    if not Environment.isGameApp(config.GAME_KEY)
      @selectedProduct.next product
    else
      newProducts = _clone products
      newProducts[i].isLoading = true
      @productsStream.next RxObservable.of newProducts

      @model.portal.call 'payments.makePurchase', {
        productId: product.productId
      }
      .then ({platform, receipt, productId, packageName}) =>
        @model.payment.verify {
          platform: platform
          receipt: receipt
          productId: productId
          packageName: packageName
          currency: product.currency
          price: product.price?.replace '$', ''
          priceMicros: product.priceMicros
        }
      .then (response) =>
        @productsStream.next @baseProducts

        # if above req fails, we finish it up in root.coffee
        @model.portal.call 'payments.consumePurchase', {
          productIds: [product.productId]
        }
        response
      .then ({transactionId, revenueUsd}) =>
        ga 'ec:addProduct', {
          'id': product.productId
          'name': product.name
          'category': 'iap'
        }
        ga 'ec:setAction', 'purchase', {
          id: transactionId
          revenue: revenueUsd
        }
        @model.portal.call 'ga.callMethod', {
          methodName: 'addTransaction'
          args: [
            product.productId, 'app'
            revenueUsd
            0
            0
            'USD'
          ]
        }

  render: =>
    {me, products} = @state.getValue()

    z '.z-currency-shop',
      if not products
        @$spinner
      else
        z '.g-grid',
          z '.g-cols',
            _map products, (product, i) =>
              {$buyButton, $currencyIcon, isLoading, productInfo} = product

              amount = productInfo.fire

              productInfo.name = "#{amount}" # FIXME

              z '.g-col.g-xs-12.g-md-6',
                z '.product',
                  z '.coin'
                  z '.right',
                    z '.info',
                      z '.amount',
                        FormatService.number amount
                        z '.icon',
                          z $currencyIcon,
                            icon: 'fire'
                            color: colors.$tertiary900
                            isTouchTarget: false
                            size: '14px'
                      z '.description',
                        @model.l.get 'currencyShop.productDescription'
                    z '.button',
                      z $buyButton,
                        text:
                          if isLoading then '...'
                          else productInfo.price
                        onclick: =>
                          if not isLoading
                            @buyProduct productInfo, i
