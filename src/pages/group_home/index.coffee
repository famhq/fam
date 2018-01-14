z = require 'zorium'
isUuid = require 'isuuid'
RxObservable = require('rxjs/Observable').Observable

Head = require '../../components/head'
GroupHome = require '../../components/group_home'
AppBar = require '../../components/app_bar'
ButtonMenu = require '../../components/button_menu'
BottomBar = require '../../components/bottom_bar'
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class GroupHomePage
  isGroup: true

  constructor: ({@model, requests, @router, serverData, overlay$}) ->
    requestsAndLanguage = RxObservable.combineLatest(
      requests, @model.l.getLanguage(), (vals...) -> vals
    )
    group = requestsAndLanguage.switchMap ([{route}, language]) =>
      if isUuid route.params.id
        @model.group.getById route.params.groupId or route.params.id
      else if route.params.groupId or route.params.id
        @model.group.getByKey route.params.groupId or route.params.id
      else
        console.log 'get', config.DEFAULT_GAME_KEY, language
        @model.group.getByGameKeyAndLanguage config.DEFAULT_GAME_KEY, language

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
    @$bottomBar = new BottomBar {@model, @router, requests, group}
    @$groupHome = new GroupHome {
      @model, @router, serverData, group, overlay$
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
      }
      @$groupHome
      @$bottomBar
