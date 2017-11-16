z = require 'zorium'
isUuid = require 'isuuid'
RxObservable = require('rxjs/Observable').Observable
require 'rxjs/add/observable/of'
require 'rxjs/add/operator/switchMap'

Head = require '../../components/head'
AppBar = require '../../components/app_bar'
ButtonMenu = require '../../components/button_menu'
Tabs = require '../../components/tabs'
Shop = require '../../components/shop'
EarnFire = require '../../components/earn_fire'
Collection = require '../../components/collection'
MenuFireAmount = require '../../components/menu_fire_amount'
Icon = require '../../components/icon'
FormatService = require '../../services/format'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class GroupShopPage
  isGroup: true

  constructor: ({@model, requests, @router, serverData, overlay$}) ->
    group = requests.switchMap ({route}) =>
      if isUuid route.params.id
        @model.group.getById route.params.id
      else
        @model.group.getByKey route.params.id

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
    @$buttonMenu = new ButtonMenu {@model, @router}
    @$tabs = new Tabs {@model}
    @$menuFireAmount = new MenuFireAmount {@model, @router}
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
    @$earnFire = new EarnFire {@model, @router, gameKey, overlay$}
    @$collection = new Collection {
      @model
      @router
      gameKey
      group
      overlay$
    }

    @state = z.state
      me: @model.user.getMe()
      windowSize: @model.window.getSize()
      gameKey: gameKey

  renderHead: => @$head

  render: =>
    {me, windowSize, gameKey} = @state.getValue()

    z '.p-group-shop', {
      style:
        height: "#{windowSize.height}px"
    },
      z @$appBar, {
        title: @model.l.get 'groupShopPage.title'
        isFlat: true
        $topLeftButton: z @$buttonMenu, {
          color: colors.$primary500
        }
        $topRightButton: @$menuFireAmount
      }
      z @$tabs,
        isBarFixed: false
        hasAppBar: true
        tabs: [
          {
            $menuText: @model.l.get 'general.shop'
            $el: @$shop
          }
          {
            $menuText: @model.l.get 'general.collection'
            $el: @$collection
          }
          {
            $menuText: @model.l.get 'general.earn'
            $el: z @$earnFire
          }
        ]
