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
    products = @model.product.getAllByGroupId(config.CLASH_ROYALE_ID)

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
