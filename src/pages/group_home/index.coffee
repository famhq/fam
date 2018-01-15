z = require 'zorium'
isUuid = require 'isuuid'
RxObservable = require('rxjs/Observable').Observable

Head = require '../../components/head'
GroupHome = require '../../components/group_home'
AppBar = require '../../components/app_bar'
ButtonMenu = require '../../components/button_menu'
SetLanguageDialog = require '../../components/set_language_dialog'
Icon = require '../../components/icon'
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class GroupHomePage
  isGroup: true
  @hasBottomBar: true

  constructor: (options) ->
    {@model, requests, @router, serverData, @overlay$,
      group, @$bottomBar} = options

    requestsAndLanguage = RxObservable.combineLatest(
      requests, @model.l.getLanguage(), (vals...) -> vals
    )
    @$head = new Head({
      @model
      requests
      serverData
      meta: {
        title: @model.l.get 'groupHomePage.title'
        description: @model.l.get 'groupHomePage.title'
      }
    })
    @$appBar = new AppBar {@model}
    @$buttonMenu = new ButtonMenu {@model, @router}
    @$settingsIcon = new Icon()
    @$groupHome = new GroupHome {
      @model, @router, serverData, group, @overlay$
    }

    @state = z.state
      windowSize: @model.window.getSize()

  renderHead: => @$head

  render: =>
    {windowSize} = @state.getValue()

    z '.p-group-home', {
      style:
        height: "#{windowSize.height}px"
    },
      z @$appBar, {
        title: @model.l.get 'general.home'
        style: 'primary'
        isFlat: true
        $topLeftButton: z @$buttonMenu, {color: colors.$primary500}
        $topRightButton: z @$settingsIcon,
          icon: 'settings'
          color: colors.$primary500
          onclick: =>
            @overlay$.next new SetLanguageDialog {
              @model, @router, @overlay$
            }
      }
      @$groupHome
      @$bottomBar
