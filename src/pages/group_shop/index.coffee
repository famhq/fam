z = require 'zorium'
isUuid = require 'isuuid'
RxObservable = require('rxjs/Observable').Observable
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject
require 'rxjs/add/observable/of'
require 'rxjs/add/operator/switchMap'

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
  @hasBottomBar: true

  constructor: (options) ->
    {@model, @requests, @router, serverData, overlay$,
      group, @$bottomBar} = options

    @selectedIndex = new RxBehaviorSubject 0

    @$appBar = new AppBar {@model}
    @$buttonMenu = new ButtonMenu {@model, @router}
    @$tabs = new Tabs {@model, @selectedIndex}
    @$menuFireAmount = new MenuFireAmount {@model, @router}
    @$shop = new Shop {
      @model
      @router
      overlay$
      goToEarnFn: =>
        @selectedIndex.next 1
      products: group.switchMap (group) =>
        if group
          @model.product.getAllByGroupId group.id
        else
          RxObservable.of null
    }
    @$specialOffers = new SpecialOffers {@model, @router, overlay$, group}
    @$earnFire = new EarnFire {@model, @router, overlay$, group}

    @state = z.state
      me: @model.user.getMe()
      windowSize: @model.window.getSize()
      language: @model.l.getLanguage()

  afterMount: =>
    @requests.take(1).subscribe ({route}) =>
      if route.params.tab is 'special-offers'
        @selectedIndex.next 1

  getMeta: =>
    {
      title: @model.l.get 'groupShopPage.title'
      description: @model.l.get 'groupShopPage.title'
    }

  render: =>
    {me, windowSize, language} = @state.getValue()

    z '.p-group-shop', {
      style:
        height: "#{windowSize.height}px"
    },
      z @$appBar, {
        title: @model.l.get 'groupShopPage.title'
        isFlat: true
        $topLeftButton: z @$buttonMenu, {
          color: colors.$header500Icon
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
          {
            $menuText: @model.l.get 'shop.specialOffers'
            $el: z @$specialOffers
          }
          {
            $menuText: @model.l.get 'general.earn'
            $el: z @$earnFire
          }
        ]
      z @$bottomBar
