z = require 'zorium'
isUuid = require 'isuuid'

Head = require '../../components/head'
GroupManageRoles = require '../../components/group_manage_roles'
AppBar = require '../../components/app_bar'
ButtonMenu = require '../../components/button_menu'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class GroupManageRolesPage
  isGroup: true

  constructor: ({@model, requests, @router, serverData, group}) ->
    user = requests.switchMap ({route}) =>
      @model.user.getById route.params.userId

    @$head = new Head({
      @model
      requests
      serverData
      meta: {
        title: @model.l.get 'groupManageRolesPage.title'
        description: @model.l.get 'groupManageRolesPage.title'
      }
    })
    @$appBar = new AppBar {@model}
    @$buttonMenu = new ButtonMenu {@model, @router}
    @$groupManageRoles = new GroupManageRoles {
      @model, @router, serverData, group, user
    }

    @state = z.state
      windowSize: @model.window.getSize()

  renderHead: => @$head

  render: =>
    {windowSize} = @state.getValue()

    z '.p-group-manage-roles', {
      style:
        height: "#{windowSize.height}px"
    },
      z @$appBar, {
        title: @model.l.get 'groupManageRolesPage.title'
        style: 'primary'
        isFlat: true
        $topLeftButton: z @$buttonMenu, {color: colors.$primary500}
      }
      @$groupManageRoles
