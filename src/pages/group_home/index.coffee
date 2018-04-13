z = require 'zorium'
isUuid = require 'isuuid'
RxObservable = require('rxjs/Observable').Observable

GroupHome = require '../../components/group_home'
AppBar = require '../../components/app_bar'
ButtonMenu = require '../../components/button_menu'
SetLanguageDialog = require '../../components/set_language_dialog'
Icon = require '../../components/icon'
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

ONE_DAY_MS = 3600 * 24 * 1000

module.exports = class GroupHomePage
  isGroup: true
  @hasBottomBar: true

  constructor: (options) ->
    {@model, @requests, @router, serverData, @overlay$,
      @group, @$bottomBar} = options

    @$appBar = new AppBar {@model}
    @$buttonMenu = new ButtonMenu {@model, @router}
    @$settingsIcon = new Icon()
    @$groupHome = new GroupHome {
      @model, @router, serverData, @group, @overlay$
    }

    @group.take(1).subscribe (group) =>
      cookieKey = "group_#{group.id}_connectionsChecked"
      hasChecked = @model.cookie.get cookieKey
      unless hasChecked
        @model.connection.giveUpgradesByGroupId group.id
        .then =>
          @model.cookie.set cookieKey, '1', {ttlMs: ONE_DAY_MS}

    @state = z.state
      windowSize: @model.window.getSize()

  getMeta: =>
    @requests.map ({req}) =>
      referrer = req.query.referrer
      lang = req.query.lang or 'en'
      apiUrl = config.PUBLIC_API_URL

      if referrer # TODO: fortnite only
        {
          # title: @model.l.get 'general.home'
          # description: @model.l.get 'general.home'
          openGraph:
            image:
              "#{apiUrl}/di/fortnite-stats/#{referrer}/#{lang}.png?3"
        }
      else
        {
          title: @model.l.get 'general.home'
        }

  render: =>
    {windowSize} = @state.getValue()

    z '.p-group-home', {
      style:
        height: "#{windowSize.height}px"
    },
      z @$appBar, {
        title: @model.l.get 'general.home'
        style: 'primary'
        $topLeftButton: z @$buttonMenu, {color: colors.$header500Icon}
        $topRightButton: z @$settingsIcon,
          icon: 'settings'
          color: colors.$header500Icon
          onclick: =>
            @overlay$.next new SetLanguageDialog {
              @model, @router, @overlay$, @group
            }
      }
      @$groupHome
      @$bottomBar
