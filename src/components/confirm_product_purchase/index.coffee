z = require 'zorium'
_isEmpty = require 'lodash/isEmpty'
_map = require 'lodash/map'
_sum = require 'lodash/sum'
_startCase = require 'lodash/startCase'
_snakeCase = require 'lodash/snakeCase'

FormatService = require '../../services/format'
AppBar = require '../app_bar'
SecondaryButton = require '../secondary_button'
PrimaryButton = require '../primary_button'
ButtonBack = require '../button_back'
MenuFireAmount = require '../menu_fire_amount'
CurrencyIcon = require '../currency_icon'
Icon = require '../icon'
config = require '../../config'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class ConfirmProductPurchase
  constructor: (options) ->
    {@model, @router, product, @onCancel,
      @onConfirm, purchaseLoadingKey, group} = options
    @$appBar = new AppBar {@model, @router}
    @$backButton = new ButtonBack {@router, @model}
    @$menuFireAmount = new MenuFireAmount {@router, @model, group}
    @$fireIcon = new Icon()
    @$currencyIcon = new CurrencyIcon {
      itemKey: product.currency
    }
    @$cancelButton = new SecondaryButton()
    @$buyButton = new PrimaryButton()

    @me = @model.user.getMe()

    @state = z.state
      me: @me
      product: product
      group: group
      currency: if product.currency is 'fire'
        @me.map ({fire}) -> {count: fire or 0}
      else if product.currency
        @model.userItem.getByItemKey product.currency
      purchaseLoadingKey: purchaseLoadingKey

  render: =>
    {me, product, currency, purchaseLoadingKey, group} = @state.getValue()

    canPurchase = currency?.count >= product.cost
    packImage = _snakeCase(product?.key).replace '_pack', ''
    packDir = product.key.split('_')[0]
    imageUrl = if product.data?.backgroundImage \
               then product.data?.backgroundImage
               else "#{config.CDN_URL}/packs/#{packDir}/#{packImage}.png"
    # buyPackForKey = if product.type is 'pack' \
    #                 then 'confirmPackPurchase.buyPackFor'
    #                 else 'confirmProductPurchase.buyProductFor'
    buyPackForKey = 'confirmProductPurchase.buyProductFor'

    z '.z-confirm-product-purchase',
      z @$appBar,
        $topLeftButton: z @$backButton, {
          color: colors.$header500Icon
          onclick: =>
            @onCancel?()
        }
        $topRightButton: @$menuFireAmount
        title: product?.name
      z '.content',
        z '.g-grid',
          z '.product',
            style:
              backgroundImage:
                "url(#{imageUrl})"
          if product?.data?.info
            z '.info',
              product.data.info

          z '.button',
            z @$cancelButton,
              $content: @model.l.get 'general.cancel'
              onclick: => @onCancel?()
            if canPurchase
              z @$buyButton,
                $content: if purchaseLoadingKey \
                          then @model.l.get 'general.loading'
                          else if product.cost is 0
                          then @model.l.get 'confirmProductPurchase.open'
                          else @model.l.get 'confirmProductPurchase.buyProduct'
                onclick: =>
                  unless purchaseLoadingKey
                    @model.signInDialog.openIfGuest me
                    .then =>
                      @onConfirm?()
            else
              z @$buyButton,
                $content: if product.currency is 'fire'
                  @model.l.get 'shop.earnMoreFire'
                else
                  @model.l.get 'shop.earnMore', {
                    replacements: {currency: currency?.item?.name or ''}
                  }
                onclick: =>
                  @onCancel?()
                  if product.currency is 'fire'
                    @router.go 'groupEarnWithType', {
                      groupId: group.key or group.id
                      type: 'fire'
                    }
                  else
                    @router.go 'groupEarnWithType', {
                      groupId: group.key or group.id
                      type: 'currency'
                    }
          z '.description',
            z '.flex',
              if canPurchase
                @model.l.get buyPackForKey, {
                  replacements:
                    cost: FormatService.number(product?.cost)
                }
              else
                @model.l.get 'confirmProductPurchase.needMoreCurrency', {
                  replacements:
                    cost: FormatService.number(product?.cost)
                }

              z '.icon',
                if product.currency is 'fire'
                  z @$fireIcon,
                    icon: 'fire'
                    size: '14px'
                    isTouchTarget: false
                    color: colors.$white
                else
                  z @$currencyIcon, {size: '14px'}
      # if not _isEmpty product?.isAvailableRequirements
      #   claimed = _sum product?.isAvailableRequirements, ({counts}) ->
      #     counts.circulating or 0
      #   total = _sum product?.isAvailableRequirements, ({counts}) ->
      #     counts.circulationLimit or 0
      #   percent = Math.floor(100 * (claimed / total))
      #   z '.product-status',
      #     z '.g-grid',
      #       z '.claimed', "#{percent}% claimed"
      #       z '.divider'
      #       _map product?.isAvailableRequirements, (requirement) ->
      #         {counts, itemType, itemSubTypes} = requirement
      #         type = if itemSubTypes?[1] \
      #                then _startCase itemSubTypes?[1]
      #                else _startCase itemSubTypes?[0]
      #         limit = if counts.circulationLimit? \
      #                 then counts.circulationLimit
      #                 else 'unlimited'
      #         z '.requirement',
      #           z '.title', type
      #           z '.count',
      #             "#{counts.circulating} / #{limit}"
