z = require 'zorium'
RxObservable = require('rxjs/Observable').Observable
require 'rxjs/add/observable/of'
require 'rxjs/add/operator/switchMap'

Head = require '../../components/head'
Shop = require '../../components/shop'
AppBar = require '../../components/app_bar'
ButtonBack = require '../../components/button_back'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class GroupShopPage
  hideDrawer: true

  constructor: ({@model, requests, @router, serverData, overlay$}) ->
    group = requests.switchMap ({route}) =>
      @model.group.getById route.params.id

    gameKey = requests.map ({route}) ->
      route?.params.gameKey or config.DEFAULT_GAME_KEY

    @$head = new Head({
      @model
      requests
      serverData
      meta: {
        title: @model.l.get 'groupShopPage.title'
        description: @model.l.get 'groupShopPage.title'
      }
    })
    @$appBar = new AppBar {@model}
    @$buttonBack = new ButtonBack {@router}
    @$shop = new Shop {
      @model
      @router
      gameKey
      overlay$
      products: group.switchMap (group) =>
        if group
          @model.product.getAllByGroupId group.id
        else
          RxObservable.of null
    }

    @state = z.state
      windowSize: @model.window.getSize()

  renderHead: => @$head

  render: =>
    {windowSize} = @state.getValue()

    z '.p-group-shop', {
      style:
        height: "#{windowSize.height}px"
    },
      z @$appBar, {
        title: @model.l.get 'groupShopPage.title'
        isFlat: true
        $topLeftButton: z @$buttonBack, {
          color: colors.$primary500
        }
      }
      @$shop
