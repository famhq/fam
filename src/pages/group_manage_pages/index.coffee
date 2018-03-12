z = require 'zorium'
isUuid = require 'isuuid'

GroupManagePages = require '../../components/group_manage_pages'
AppBar = require '../../components/app_bar'
ButtonMenu = require '../../components/button_menu'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class GroupManagePagesPage
  isGroup: true

  constructor: ({@model, requests, @router, serverData, group}) ->
    user = requests.switchMap ({route}) =>
      @model.user.getById route.params.userId

    @$appBar = new AppBar {@model}
    @$buttonMenu = new ButtonMenu {@model, @router}
    @$groupManagePages = new GroupManagePages {
      @model, @router, serverData, group, user
    }

    @state = z.state
      windowSize: @model.window.getSize()

  getMeta: =>
    {
      title: @model.l.get 'groupManagePagesPage.title'
      description: @model.l.get 'groupManagePagesPage.title'
    }

  render: =>
    {windowSize} = @state.getValue()

    z '.p-group-manage-pages', {
      style:
        height: "#{windowSize.height}px"
    },
      z @$appBar, {
        title: @model.l.get 'groupManagePagesPage.title'
        style: 'primary'
        $topLeftButton: z @$buttonMenu, {color: colors.$header500Icon}
      }
      @$groupManagePages
