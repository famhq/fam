z = require 'zorium'
isUuid = require 'isuuid'

Head = require '../../components/head'
GroupManageMember = require '../../components/group_manage_member'
AppBar = require '../../components/app_bar'
ButtonBack = require '../../components/button_back'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class GroupManageMemberPage
  hideDrawer: true
  isGroup: true

  constructor: ({model, requests, @router, serverData}) ->
    group = requests.switchMap ({route}) ->
      if isUuid route.params.id
        model.group.getById route.params.id
      else
        model.group.getByKey route.params.id

    user = requests.switchMap ({route}) ->
      model.user.getById route.params.userId

    @$head = new Head({
      model
      requests
      serverData
      meta: {
        title: @model.l.get 'groupManageMemberPage.title'
        description: @model.l.get 'groupManageMemberPage.title'
      }
    })
    @$appBar = new AppBar {@model}
    @$buttonBack = new ButtonBack {@model, @router}
    @$groupManageMember = new GroupManageMember {
      model, @router, serverData, group, user
    }

    @state = z.state
      windowSize: model.window.getSize()

  renderHead: => @$head

  render: =>
    {windowSize} = @state.getValue()

    z '.p-group-manage-member', {
      style:
        height: "#{windowSize.height}px"
    },
      z @$appBar, {
        title: @model.l.get 'groupManageMemberPage.title'
        style: 'primary'
        isFlat: true
        $topLeftButton: z @$buttonBack, {color: colors.$primary500}
      }
      @$groupManageMember
