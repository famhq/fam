z = require 'zorium'
isUuid = require 'isuuid'
_filter = require 'lodash/filter'
RxObservable = require('rxjs/Observable').Observable
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject
require 'rxjs/add/observable/of'
require 'rxjs/add/operator/switchMap'

AppBar = require '../../components/app_bar'
ButtonMenu = require '../../components/button_menu'
Tabs = require '../../components/tabs'
EarnCurrency = require '../../components/group_earn_currency'
EarnFire = require '../../components/earn_fire'
SpecialOffers = require '../../components/special_offers'
MenuFireAmount = require '../../components/menu_fire_amount'
Icon = require '../../components/icon'
Environment = require '../../services/environment'
FormatService = require '../../services/format'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class GroupEarnPage
  isGroup: true

  constructor: (options) ->
    {@model, @requests, @router, @serverData, overlay$,
      group, @$bottomBar} = options

    @selectedIndex = new RxBehaviorSubject 0

    @$appBar = new AppBar {@model}
    @$buttonMenu = new ButtonMenu {@model, @router}
    @$tabs = new Tabs {@model, @selectedIndex}
    @$menuFireAmount = new MenuFireAmount {@model, @router, group}
    @$specialOffers = new SpecialOffers {@model, @router, overlay$, group}
    @$earnFire = new EarnFire {@model, @router, overlay$, group}
    @$earnCurrency = new EarnCurrency {@model, @router, overlay$, group}

    @state = z.state
      me: @model.user.getMe()
      group: group
      windowSize: @model.window.getSize()
      language: @model.l.getLanguage()

  afterMount: =>
    userAgent = @serverData?.req?.headers?['user-agent'] or
                  navigator?.userAgent or ''
    isiOS = Environment.isiOS {userAgent}
    @requests.take(1).subscribe ({route}) =>
      if route.params.type is 'currency' and isiOS
        @selectedIndex.next 1
      else if route.params.type is 'currency'
        @selectedIndex.next 2

  getMeta: =>
    {
      title: @model.l.get 'general.earn'
    }

  render: =>
    {me, group, windowSize, language} = @state.getValue()

    userAgent = @serverData?.req?.headers?['user-agent'] or
                  navigator?.userAgent or ''

    z '.p-group-shop', {
      style:
        height: "#{windowSize.height}px"
    },
      z @$appBar, {
        title: @model.l.get 'general.earn'
        isFlat: true
        $topLeftButton: z @$buttonMenu, {
          color: colors.$header500Icon
        }
        $topRightButton: @$menuFireAmount
      }
      if group
        z @$tabs,
          isBarFixed: false
          hasAppBar: true
          tabs: _filter [
            {
              $menuText: group?.currency?.name or 'XP'
              $el: z @$earnCurrency
            }
            unless Environment.isiOS {userAgent}
              {
                $menuText: @model.l.get 'general.fire'
                $el: z @$specialOffers
              }
            {
              $menuText: @model.l.get 'shop.moreFire'
              $el: z @$earnFire
            }
          ]
      z @$bottomBar
