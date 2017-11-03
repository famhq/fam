z = require 'zorium'
isUuid = require 'isuuid'
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject

Head = require '../../components/head'
GroupMembers = require '../../components/group_members'
AppBar = require '../../components/app_bar'
ButtonBack = require '../../components/button_back'
ProfileDialog = require '../../components/profile_dialog'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class GroupManageMemberPage
  hideDrawer: true

  constructor: ({@model, requests, @router, serverData}) ->
    group = requests.switchMap ({route}) =>
      if isUuid route.params.id
        @model.group.getById route.params.id
      else
        @model.group.getByKey route.params.id

    gameKey = requests.map ({route}) ->
      route.params.gameKey or config.DEFAULT_GAME_KEY

    @$head = new Head({
      @model
      requests
      serverData
      meta: {
        title: @model.l.get 'groupMembersPage.title'
        description: @model.l.get 'groupMembersPage.title'
      }
    })

    selectedProfileDialogUser = new RxBehaviorSubject null

    @$appBar = new AppBar {@model}
    @$buttonBack = new ButtonBack {@model, @router}
    @$groupMembers = new GroupMembers {
      @model, @router, serverData, group, selectedProfileDialogUser, gameKey
    }

    @$profileDialog = new ProfileDialog {
      @model, @router, group, selectedProfileDialogUser, gameKey
    }

    @state = z.state
      windowSize: @model.window.getSize()
      selectedProfileDialogUser: selectedProfileDialogUser

  renderHead: => @$head

  render: =>
    {windowSize, selectedProfileDialogUser} = @state.getValue()

    z '.p-group-manage-member', {
      style:
        height: "#{windowSize.height}px"
    },
      z @$appBar, {
        title: @model.l.get 'groupMembersPage.title'
        style: 'primary'
        isFlat: true
        $topLeftButton: z @$buttonBack, {color: colors.$primary500}
      }
      @$groupMembers

      if selectedProfileDialogUser
        @$profileDialog
