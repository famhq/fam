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
Icon = require '../icon'
config = require '../../config'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class ConfirmPackPurchase
  constructor: (options) ->
    {@model, @router, pack, @onCancel, @onConfirm, isPurchaseLoading} = options
    @$appBar = new AppBar {@model, @router}
    @$backButton = new ButtonBack {@router, @model}
    @$closeIcon = new Icon()
    @$fireIcon = new Icon()
    @$fireIcon2 = new Icon()
    @$cancelButton = new SecondaryButton()
    @$buyButton = new PrimaryButton()

    @me = @model.user.getMe()

    @state = z.state
      me: @me
      pack: pack
      isPurchaseLoading: isPurchaseLoading

  render: =>
    {me, pack, isPurchaseLoading} = @state.getValue()

    packImage = _snakeCase(pack?.key).replace '_pack', ''

    z '.z-confirm-pack-purchase',
      z @$appBar,
        $topLeftButton: z @$backButton, {
          onclick: =>
            @onCancel?()
        }
        $topRightButton:
          z '.z-confirm-pack-purchase_currency-amount',
            z '.amount', FormatService.number me?.fire
            z @$fireIcon,
              icon: 'fire'
              isTouchTarget: false
              color: colors.$tertiary900Text
              size: '16px'
        title: pack?.title
      z '.content',
        z '.g-grid',
          z '.pack',
            style:
              backgroundImage: "url(#{config.CDN_URL}/packs/#{packImage}.png)"
          z '.button',
            z @$cancelButton,
              $content: @model.l.get 'general.cancel'
              onclick: => @onCancel?()
            z @$buyButton,
              $content: if isPurchaseLoading \
                        then @model.l.get 'general.loading'
                        else @model.l.get 'confirmPackPurchase.buyPack'
              onclick: =>
                unless isPurchaseLoading
                  @onConfirm?()
          z '.description',
            z '.flex',
              @model.l.get 'confirmPackPurchase.buyPackFor', {
                replacements:
                  cost: FormatService.number(pack?.cost)
              }
              z '.icon',
                z @$fireIcon2,
                  icon: 'fire'
                  size: '14px'
                  isTouchTarget: false
                  color: colors.$white
              '?'
      # if not _isEmpty pack?.isAvailableRequirements
      #   claimed = _sum pack?.isAvailableRequirements, ({counts}) ->
      #     counts.circulating or 0
      #   total = _sum pack?.isAvailableRequirements, ({counts}) ->
      #     counts.circulationLimit or 0
      #   percent = Math.floor(100 * (claimed / total))
      #   z '.pack-status',
      #     z '.g-grid',
      #       z '.claimed', "#{percent}% claimed"
      #       z '.divider'
      #       _map pack?.isAvailableRequirements, (requirement) ->
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
