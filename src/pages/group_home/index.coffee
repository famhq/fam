z = require 'zorium'
isUuid = require 'isuuid'

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

  constructor: ({@model, requests, @router, serverData}) ->
    group = requests.switchMap ({route}) =>
      if isUuid route.params.id
        @model.group.getById route.params.groupId or route.params.id
      else
        @model.group.getByKey route.params.groupId or route.params.id

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
      @model, @router, serverData, group
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
