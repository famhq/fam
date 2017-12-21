z = require 'zorium'
isUuid = require 'isuuid'

Head = require '../../components/head'
GroupManageChannels = require '../../components/group_manage_channels'
AppBar = require '../../components/app_bar'
ButtonMenu = require '../../components/button_menu'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class GroupManageChannelsPage
  isGroup: true

  constructor: ({@model, requests, @router, serverData}) ->
    group = requests.switchMap ({route}) =>
      if isUuid route.params.id
        @model.group.getById route.params.id
      else
        @model.group.getByKey route.params.id

    user = requests.switchMap ({route}) =>
      @model.user.getById route.params.userId

    gameKey = requests.map ({route}) ->
      route.params.gameKey or config.DEFAULT_GAME_KEY

    @$head = new Head({
      @model
      requests
      serverData
      meta: {
        title: @model.l.get 'groupManageChannelsPage.title'
        description: @model.l.get 'groupManageChannelsPage.title'
      }
    })
    @$appBar = new AppBar {@model}
    @$buttonMenu = new ButtonMenu {@model, @router}
    @$groupManageChannels = new GroupManageChannels {
      @model, @router, serverData, group, user, gameKey
    }

    @state = z.state
      windowSize: @model.window.getSize()

  renderHead: => @$head

  render: =>
    {windowSize} = @state.getValue()

    z '.p-group-manage-channels', {
      style:
        height: "#{windowSize.height}px"
    },
      z @$appBar, {
        title: @model.l.get 'groupManageChannelsPage.title'
        style: 'primary'
        isFlat: true
        $topLeftButton: z @$buttonMenu, {color: colors.$primary500}
      }
      @$groupManageChannels
