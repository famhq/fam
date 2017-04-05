z = require 'zorium'
Rx = require 'rx-lite'

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

  constructor: ({model, requests, @router, serverData}) ->
    group = requests.flatMapLatest ({route}) ->
      model.group.getById route.params.id

    @$head = new Head({
      model
      requests
      serverData
      meta: {
        title: 'Group Members'
        description: 'Group Members'
      }
    })

    selectedProfileDialogUser = new Rx.BehaviorSubject null

    @$appBar = new AppBar {model}
    @$buttonBack = new ButtonBack {model, @router}
    @$groupMembers = new GroupMembers {
      model, @router, serverData, group, selectedProfileDialogUser
    }

    @$profileDialog = new ProfileDialog {
      model, @router, group, selectedProfileDialogUser
    }

    @state = z.state
      windowSize: model.window.getSize()
      selectedProfileDialogUser: selectedProfileDialogUser

  renderHead: => @$head

  render: =>
    {windowSize, selectedProfileDialogUser} = @state.getValue()

    z '.p-group-manage-member', {
      style:
        height: "#{windowSize.height}px"
    },
      z @$appBar, {
        title: 'Group Members'
        style: 'secondary'
        isFlat: true
        $topLeftButton: z @$buttonBack, {color: colors.$primary500}
      }
      @$groupMembers

      if selectedProfileDialogUser
        @$profileDialog
