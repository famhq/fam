z = require 'zorium'
isUuid = require 'isuuid'
_filter = require 'lodash/filter'
Environment = require 'clay-environment'
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject
require 'rxjs/add/operator/map'

Head = require '../../components/head'
AppBar = require '../../components/app_bar'
ButtonMenu = require '../../components/button_menu'
Tabs = require '../../components/tabs'
GroupBannedUsers = require '../../components/group_banned_users'
ProfileDialog = require '../../components/profile_dialog'
config = require '../../config'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class GroupBannedUsersPage
  isGroup: true

  constructor: ({@model, requests, @router, serverData, group}) ->
    @$head = new Head({
      @model
      requests
      serverData
      meta: {
        title: @model.l.get 'groupBannedUsersPage.title'
        description: @model.l.get 'groupBannedUsersPage.title'
      }
    })
    @$appBar = new AppBar {@model}
    @$buttonMenu = new ButtonMenu {@model, @router}

    @selectedProfileDialogUser = new RxBehaviorSubject null
    @$profileDialog = new ProfileDialog {
      @model, @portal, @router, @selectedProfileDialogUser, group
    }

    @$tempBanned = new GroupBannedUsers {
      @model
      selectedProfileDialogUser: @selectedProfileDialogUser
      bans: group.switchMap (group) =>
        @model.ban.getAllByGroupId group.id, {duration: '24h'}
    }

    @$permBanned = new GroupBannedUsers {
      @model
      selectedProfileDialogUser: @selectedProfileDialogUser
      bans: group.switchMap (group) =>
        @model.ban.getAllByGroupId group.id, {duration: 'permanent'}
    }
    @$tabs = new Tabs {@model}

    @state = z.state
      group: group
      windowSize: @model.window.getSize()
      selectedProfileDialogUser: @selectedProfileDialogUser

  renderHead: => @$head

  render: =>
    {group, windowSize, selectedProfileDialogUser} = @state.getValue()

    z '.p-group-banned-users', {
      style:
        height: "#{windowSize.height}px"
    },
      z @$appBar, {
        title: @model.l.get 'groupBannedUsersPage.title'
        style: 'primary'
        isFlat: true
        $topLeftButton: z @$buttonMenu, {color: colors.$primary500}
      }
      z @$tabs,
        isBarFixed: false
        hasAppBar: true
        tabs: [
          {
            $menuText: @model.l.get 'groupBannedUsersPage.tempBanned'
            $el: @$tempBanned
          }
          {
            $menuText: @model.l.get 'groupBannedUsersPage.permBanned'
            $el: z @$permBanned
          }
        ]
      if selectedProfileDialogUser
        @$profileDialog
