z = require 'zorium'
isUuid = require 'isuuid'
RxObservable = require('rxjs/Observable').Observable
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject
require 'rxjs/add/observable/of'
require 'rxjs/add/operator/switchMap'

Head = require '../../components/head'
AppBar = require '../../components/app_bar'
ButtonMenu = require '../../components/button_menu'
Tabs = require '../../components/tabs'
Shop = require '../../components/shop'
EarnFire = require '../../components/earn_fire'
SpecialOffers = require '../../components/special_offers'
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
    selectedIndex = new RxBehaviorSubject 0
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
    @$tabs = new Tabs {@model, selectedIndex}
    @$menuFireAmount = new MenuFireAmount {@model, @router}
    @$shop = new Shop {
      @model
      @router
      gameKey
      overlay$
      goToEarnFn: ->
        selectedIndex.next 1
      products: group.switchMap (group) =>
        if group
          @model.product.getAllByGroupId group.id
        else
          RxObservable.of null
    }
    @$specialOffers = new SpecialOffers {@model, @router, gameKey, overlay$}
    @$earnFire = new EarnFire {@model, @router, gameKey, overlay$}

    @state = z.state
      me: @model.user.getMe()
      windowSize: @model.window.getSize()
      gameKey: gameKey
      language: @model.l.getLanguage()

  renderHead: => @$head

  render: =>
    {me, windowSize, gameKey, language} = @state.getValue()

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
      # if language is 'es'
      #   @$shop
      # else
      z @$tabs,
        isBarFixed: false
        hasAppBar: true
        tabs: [
          {
            $menuText: @model.l.get 'general.shop'
            $el: @$shop
          }
          # {
          #   $menuText: @model.l.get 'shop.specialOffers'
          #   $el: z @$specialOffers
          # }
          {
            $menuText: @model.l.get 'general.earn'
            $el: z @$earnFire
          }
        ]
