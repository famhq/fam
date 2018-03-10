z = require 'zorium'
isUuid = require 'isuuid'
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject

AppBar = require '../../components/app_bar'
Collection = require '../../components/collection'
Shop = require '../../components/shop'
Tabs = require '../../components/tabs'
ButtonMenu = require '../../components/button_menu'
MenuFireAmount = require '../../components/menu_fire_amount'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class GroupCollectionPage
  isGroup: true
  @hasBottomBar: true

  constructor: ({@model, @requests, @router, overlay$, group, @$bottomBar}) ->
    @selectedIndex = new RxBehaviorSubject 0
    @$appBar = new AppBar {@model}
    @$buttonMenu = new ButtonMenu {@model, @router}
    @$tabs = new Tabs {@model, @selectedIndex}
    @$collection = new Collection {
      @model
      @router
      group
      overlay$
      @selectedIndex
    }
    @$shop = new Shop {
      @model
      @router
      overlay$
      group: group
      goToEarnFn: =>
        {group} = @state.getValue()
        @router.go 'groupEarnFire', {groupId: group.id}
      products: group.switchMap (group) =>
        if group
          @model.product.getAllByGroupId group.id
        else
          RxObservable.of null
    }
    @$menuFireAmount = new MenuFireAmount {@model, @router, group}

    @state = z.state
      group: group
      windowSize: @model.window.getSize()

  getMeta: =>
    {
      title: @model.l.get 'collectionPage.title'
      description: @model.l.get 'collectionPage.title'
    }

  afterMount: =>
    @requests.take(1).subscribe ({route}) =>
      if route.params.tab is 'shop'
        @selectedIndex.next 1
      else
        @selectedIndex.next 0

  render: =>
    {windowSize} = @state.getValue()

    z '.p-group-collection', {
      style:
        height: "#{windowSize.height}px"
    },
      z @$appBar, {
        title: @model.l.get 'collectionPage.title'
        isFlat: true
        $topLeftButton: z @$buttonMenu, {
          color: colors.$header500Icon
        }
        $topRightButton: @$menuFireAmount
      }

      z @$tabs,
        isBarFixed: false
        hasAppBar: true
        tabs: [
          {
            $menuText: @model.l.get 'collectionPage.title'
            $el: @$collection
          }
          {
            $menuText: @model.l.get 'general.shop'
            $el: @$shop
          }
        ]

      @$bottomBar
