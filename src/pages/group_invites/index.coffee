z = require 'zorium'

Head = require '../../components/head'
GroupList = require '../../components/group_list'
AppBar = require '../../components/app_bar'
ButtonBack = require '../../components/button_back'

if window?
  require './index.styl'

module.exports = class GroupInvitePage
  hideDrawer: true

  constructor: ({@model, requests, @router, serverData}) ->
    group = requests.flatMapLatest ({route}) ->
      @model.group.getById route.params.id

    @$head = new Head({
      @model
      requests
      serverData
      meta: {
        title: 'Group Invites'
        description: 'Group Invites'
      }
    })
    @$appBar = new AppBar()
    @$buttonBack = new ButtonBack {@router}
    @$groupList = new GroupList {
      @router
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
        title: 'Group Invites'
        isFlat: true
        $topLeftButton: z @$buttonBack
      }
      z '.list',
        @$groupList
