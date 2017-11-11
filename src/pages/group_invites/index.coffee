z = require 'zorium'
isUuid = require 'isuuid'

Head = require '../../components/head'
GroupList = require '../../components/group_list'
AppBar = require '../../components/app_bar'
ButtonBack = require '../../components/button_back'

if window?
  require './index.styl'

module.exports = class GroupInvitePage
  hideDrawer: true
  isGroup: true

  constructor: ({@model, requests, @router, serverData}) ->
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
        title: @model.l.get 'groupInvitesPage.title'
        description: @model.l.get 'groupInvitesPage.title'
      }
    })
    @$appBar = new AppBar {@model}
    @$buttonBack = new ButtonBack {@router}
    @$groupList = new GroupList {
      @router
      gameKey
      groups: @model.group.getAll {filter: 'invited'}
    }

    @state = z.state
      windowSize: @model.window.getSize()

  renderHead: => @$head

  afterMount: =>
    @model.userData.updateMe {unreadGroupInvites: 0}

  render: =>
    {windowSize} = @state.getValue()

    z '.p-group-invites', {
      style:
        height: "#{windowSize.height}px"
    },
      z @$appBar, {
        title: @model.l.get 'groupInvitesPage.title'
        isFlat: true
        $topLeftButton: z @$buttonBack
      }
      z '.list',
        @$groupList
