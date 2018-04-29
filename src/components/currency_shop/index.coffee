z = require 'zorium'
_map = require 'lodash/map'
_clone = require 'lodash/clone'
RxObservable = require('rxjs/Observable').Observable
RxReplaySubject = require('rxjs/ReplaySubject').ReplaySubject
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject
require 'rxjs/add/observable/of'

Icon = require '../icon'
Spinner = require '../spinner'
PrimaryButton = require '../primary_button'
StripeDialog = require '../stripe_dialog'
FormatService = require '../../services/format'
Environment = require '../../services/environment'
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class CurrencyShop
  constructor: ({@model, group, @overlay$}) ->
    @$spinner = new Spinner()
    @$newIcon = new Icon()

    @isImpressionSent = false
    @selectedIap = new RxBehaviorSubject null

    if window?
      userAgent = navigator?.userAgent
      platform = Environment.getPlatform {userAgent}

      iaps = @model.iap.getAllByPlatform platform
    else
      iaps = RxObservable.of []

    @$stripeDialog = new StripeDialog {
      @model, group, iap: @selectedIap, @overlay$
    }

    @state = z.state
      me: @model.user.getMe()
      group: group
      loadingIapKey: null
      iaps: iaps.map (iaps) =>
        iaps = _map iaps, (iap, i) =>
          unless @isImpressionSent
            position = i + 1
            ga 'ec:addImpression', {
              'id': iap.key
              'name': iap.name
              'category': 'IAP'
              'list': 'shopv1'
              'position': position
            }
            ga 'send', 'event', 'shop', iap.key, 'impression'

          return {
            $buyButton: new PrimaryButton()
            $currencyIcon: new Icon()
            iapInfo: iap
          }
      platform: Environment.getPlatform {gameKey: config.GAME_KEY}

  beforeUnmount: =>
    @isImpressionSent = false

  buy: (iap, i) =>
    {platform, iaps, group} = @state.getValue()

    ga 'ec:addProduct', {
      'id': iap.key
      'name': iap.name
      'category': 'iap'
    }
    ga 'ec:setAction', 'detail'
    ga 'send', 'event', 'shop', iap.key, 'click'

    if not Environment.isNativeApp(config.GAME_KEY)
      @selectedIap.next iap
      @overlay$.next @$stripeDialog
    else
      @state.set loadingIapKey: iap.key
      productId = "#{group.googlePlayAppId}.#{iap.key}"
      @model.portal.call 'payments.makePurchase', {productId}
      .then ({platform, receipt, key, packageName}) =>
        @model.payment.verify {
          platform: platform
          groupId: group.id
          receipt: receipt
          productId: productId
          packageName: packageName
          currency: iap.currency
          price: iap.price?.replace '$', ''
          priceMicros: iap.priceMicros
        }
      .then (response) =>
        @state.set loadingIapKey: null
        # if above req fails, we finish it up in root.coffee
        @model.portal.call 'payments.finishPurchase', {
          productIds: [productId]
        }
        response
      .then ({transactionId, revenueUsd}) =>
        ga? 'ec:addProduct', {
          'id': iap.key
          'name': iap.name
          'category': 'iap'
        }
        ga? 'ec:setAction', 'purchase', {
          id: transactionId
          revenue: revenueUsd
        }
      .catch =>
        @state.set loadingIapKey: null

  render: =>
    {me, iaps, loadingIapKey} = @state.getValue()

    z '.z-currency-shop',
      if not iaps
        @$spinner
      else
        z '.g-grid',
          z '.g-cols',
            _map iaps, (iap, i) =>
              {$buyButton, $currencyIcon, iapInfo} = iap

              isLoading = iapInfo.key is loadingIapKey

              amount = iapInfo.data.fireAmount
              priceUsd = iapInfo.priceCents / 100

              iapInfo.name = "#{amount}"

              z '.g-col.g-xs-12.g-md-6',
                z '.iap',
                  z '.info',
                    z '.amount',
                      FormatService.number amount
                      z '.icon',
                        z $currencyIcon,
                          icon: 'fire'
                          color: colors.$quaternary500
                          isTouchTarget: false
                          size: '16px'
                  z '.button',
                    z $buyButton,
                      text:
                        if isLoading then '...'
                        else "$#{priceUsd}"
                      onclick: =>
                        if not isLoading
                          @model.signInDialog.openIfGuest me
                          .then =>
                            @buy iapInfo, i
