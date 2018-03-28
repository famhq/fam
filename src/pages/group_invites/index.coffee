z = require 'zorium'
isUuid = require 'isuuid'

GroupList = require '../../components/group_list'
AppBar = require '../../components/app_bar'
ButtonBack = require '../../components/button_back'

if window?
  require './index.styl'

module.exports = class GroupInvitePage
  hideDrawer: true
  isGroup: true

  constructor: ({@model, requests, @router, serverData, group}) ->
    @$appBar = new AppBar {@model}
    @$buttonBack = new ButtonBack {@router}
    @$groupList = new GroupList {
      @router
      groups: @model.group.getAll {filter: 'invited'}
    }

    @state = z.state
      windowSize: @model.window.getSize()

  getMeta: =>
    {
      title: @model.l.get 'groupInvitesPage.title'
    }

  # afterMount: =>
  #   @model.userData.updateMe {unreadGroupInvites: 0}

  render: =>
    {windowSize} = @state.getValue()

    z '.p-group-invites', {
      style:
        height: "#{windowSize.height}px"
    },
      z @$appBar, {
        title: @model.l.get 'groupInvitesPage.title'
        $topLeftButton: z @$buttonBack
      }
      z '.list',
        @$groupList
