z = require 'zorium'
_map = require 'lodash/map'
_defaults = require 'lodash/defaults'
_filter = require 'lodash/filter'
RxObservable = require('rxjs/Observable').Observable
require 'rxjs/add/observable/combineLatest'
require 'rxjs/add/operator/map'

PrimaryButton = require '../primary_button'
Icon = require '../icon'
Shop = require '../shop'
FormatService = require '../../services/format'
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class SpendFire
  constructor: ({@model, @router, @overlay$, gameKey}) ->
    productsAndMe = RxObservable.combineLatest(
      @model.product.getAllByGroupId(config.CLASH_ROYALE_ID)
      @model.user.getMe()
      (vals...) -> vals
    )
    products = productsAndMe.map ([products, me]) ->
      country = me?.country?.toLowerCase()
      _filter _map products, (product) ->
        if product.key is 'google_play_10'
          unless country in ['mx', 'us', 'br', 'kr', 'jp']
            return
          product.name = if country is 'us' \
                 then '$10 Google Play gift card'
                 else if country is 'mx'
                 then '200 MXN Google Play tarjeta de regalo'
                 else if country is 'br'
                 then '30 BRL Google Play cartão presente'
                 else if country is 'kr'
                 then '10,000 WON Google Play 기프트 카드'
        product

    @$shop = new Shop {
      @model, @router, gameKey, products, @overlay$
    }

    me = @model.user.getMe()
    @state = z.state
      me: me

  render: =>
    {me, items} = @state.getValue()

    z '.z-spend-fire',
      z 'p.description', @model.l.get 'spendFire.description1'
      z @$shop
