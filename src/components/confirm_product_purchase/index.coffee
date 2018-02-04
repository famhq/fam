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
Icon = require '../icon'
config = require '../../config'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class ConfirmProductPurchase
  constructor: (options) ->
    {@model, @router, product, @onCancel,
      @onConfirm, purchaseLoadingKey} = options
    @$appBar = new AppBar {@model, @router}
    @$backButton = new ButtonBack {@router, @model}
    @$menuFireAmount = new MenuFireAmount {@router, @model}
    @$fireIcon = new Icon()
    @$cancelButton = new SecondaryButton()
    @$buyButton = new PrimaryButton()

    @me = @model.user.getMe()

    @state = z.state
      me: @me
      product: product
      purchaseLoadingKey: purchaseLoadingKey

  render: =>
    {me, product, purchaseLoadingKey} = @state.getValue()

    packImage = _snakeCase(product?.key).replace '_pack', ''
    imageUrl = if product.data?.backgroundImage \
               then product.data?.backgroundImage
               else "#{config.CDN_URL}/packs/#{packImage}.png"
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
            z @$buyButton,
              $content: if purchaseLoadingKey \
                        then @model.l.get 'general.loading'
                        # else if product.type is 'pack'
                        # then @model.l.get 'confirmPackPurchase.buyPack'
                        else if product.cost is 0
                        then @model.l.get 'confirmProductPurchase.open'
                        else @model.l.get 'confirmProductPurchase.buyProduct'
              onclick: =>
                unless purchaseLoadingKey
                  @model.signInDialog.openIfGuest me
                  .then =>
                    @onConfirm?()
          z '.description',
            z '.flex',
              @model.l.get buyPackForKey, {
                replacements:
                  cost: FormatService.number(product?.cost)
              }
              z '.icon',
                z @$fireIcon,
                  icon: 'fire'
                  size: '14px'
                  isTouchTarget: false
                  color: colors.$white
              '?'
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
