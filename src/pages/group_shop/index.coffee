z = require 'zorium'
isUuid = require 'isuuid'
RxObservable = require('rxjs/Observable').Observable
require 'rxjs/add/observable/of'
require 'rxjs/add/operator/switchMap'

Head = require '../../components/head'
AppBar = require '../../components/app_bar'
ButtonBack = require '../../components/button_back'
Tabs = require '../../components/tabs'
Shop = require '../../components/shop'
Collection = require '../../components/collection'
Icon = require '../../components/icon'
FormatService = require '../../services/format'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class GroupShopPage
  hideDrawer: true

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
    @$buttonBack = new ButtonBack {@router}
    @$tabs = new Tabs {@model}
    @$fireIcon = new Icon()
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
    @$collection = new Collection {
      @model
      @router
      gameKey
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
        $topLeftButton: z @$buttonBack, {
          color: colors.$primary500
        }
        $topRightButton: z '.p-fire_top-right', {
          onclick: =>
            @router.go 'fire', {gameKey}
        },
          FormatService.number me?.fire
          z '.icon',
            z @$fireIcon,
              icon: 'fire'
              color: colors.$quaternary500
              isTouchTarget: false
              size: '20px'
      }

      z @$tabs,
        isBarFixed: false
        hasAppBar: true
        tabs: [
          {
            $menuText: @model.l.get 'general.shop'
            $el:
              z '.p-group-shop_shop', z @$shop
          }
          {
            $menuText: @model.l.get 'general.collection'
            $el:
              z '.p-group-shop_collection', z @$collection
          }
        ]
