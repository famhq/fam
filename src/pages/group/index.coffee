z = require 'zorium'
Rx = require 'rx-lite'
_filter = require 'lodash/filter'

Head = require '../../components/head'
AppBar = require '../../components/app_bar'
ButtonBack = require '../../components/button_back'
GroupInfo = require '../../components/group_info'
GroupChat = require '../../components/group_chat'
GroupAnnouncements = require '../../components/group_announcements'
GroupMembers = require '../../components/group_members'
ProfileDialog = require '../../components/profile_dialog'
Tabs = require '../../components/tabs'
Icon = require '../../components/icon'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class GroupPage
  hideDrawer: true

  constructor: ({@model, requests, @router, serverData}) ->
    selectedProfileDialogUser = new Rx.BehaviorSubject null
    selectedIndex = new Rx.BehaviorSubject 0

    overlay$ = new Rx.BehaviorSubject null

    groupId = requests.map ({route}) ->
      route.params.id

    group = groupId.flatMapLatest (groupId) =>
      @model.group.getById groupId


    me = @model.user.getMe()

    groupAndMe = Rx.Observable.combineLatest(
      group
      me
      (vals...) -> vals
    )

    @$head = new Head({
      @model
      requests
      serverData
      # FIXME: doesn't currently work
      # https://github.com/claydotio/zorium/commit/42f5e05f109b9954f056fb2bab3dba48fd43e90c
      meta: null
      # group.map (group) ->
      #   title: group.name
      #   description: group.name
    })
    @$appBar = new AppBar {@model}
    @$buttonBack = new ButtonBack {@model, @router}
    @$groupInfo = new GroupInfo {@model, @router, group}
    @$groupChat = new GroupChat {
      @model
      @router
      selectedProfileDialogUser
      overlay$
      isActive: selectedIndex.map (index) ->
        index is 1
      conversation: groupAndMe.flatMapLatest ([group, me]) =>
        hasMemberPermission = @model.group.hasPermission group, me
        if hasMemberPermission
          @model.conversation.getByGroupId group.id
        else
          Rx.Observable.just null
    }
    @$groupAnnouncements = new GroupAnnouncements {@model, @router, group}
    @$groupMembers = new GroupMembers {
      @model, @router, group, selectedProfileDialogUser
    }
    @$tabs = new Tabs {@model, selectedIndex}
    @$editIcon = new Icon()
    @$settingsIcon = new Icon()
    @$groupInfoIcon = new Icon()
    @$groupChatIcon = new Icon()
    @$groupAnnouncementsIcon = new Icon()
    @$groupMembersIcon = new Icon()
    @$profileDialog = new ProfileDialog {
      @model
      @router
      selectedProfileDialogUser
    }

    @state = z.state
      group: group
      me: me
      overlay$: overlay$
      selectedProfileDialogUser: selectedProfileDialogUser

  renderHead: => @$head

  render: =>
    {group, me, overlay$, selectedProfileDialogUser} = @state.getValue()

    console.log group
    hasMemberPermission = @model.group.hasPermission group, me
    console.log hasMemberPermission
    hasAdminPermission = @model.group.hasPermission group, me, {level: 'admin'}

    z '.p-group', {
      style:
        height: "#{window?.innerHeight}px"
    },
      z @$appBar, {
        title: group?.name
        bgColor: colors.$tertiary700
        isFlat: true
        $topLeftButton: z @$buttonBack, {color: colors.$primary500}
        $topRightButton:
          z '.p-group_top-right',
            z '.icon',
              if hasAdminPermission
                z @$editIcon,
                  icon: 'edit'
                  color: colors.$primary500
                  onclick: =>
                    @router.go "/group/#{group?.id}/edit"
            z '.icon',
              z @$settingsIcon,
                icon: 'settings'
                color: colors.$primary500
                onclick: =>
                  @router.go "/group/#{group?.id}/settings"

      }
      # don't load prematurely, or 4 tabs will go to 2 and break vDomKey
      if group and me
        z @$tabs,
          isBarFixed: false
          barBgColor: colors.$tertiary700
          barInactiveColor: colors.$white
          tabs: _filter [
            if hasMemberPermission
              {
                $menuIcon: @$groupChatIcon
                menuIconName: 'chat-bubble'
                $menuText: 'Chat'
                $el: @$groupChat
              }
            {
              $menuIcon: @$groupInfoIcon
              menuIconName: 'info'
              $menuText: 'Info'
              $el: @$groupInfo
            }
            if hasMemberPermission
              {
                $menuIcon: @$groupAnnouncementsIcon
                menuIconName: 'notifications'
                $menuText: 'Announcements'
                $el: @$groupAnnouncements
              }
            {
              $menuIcon: @$groupMembersIcon
              menuIconName: 'friends'
              $menuText: 'Members'
              $el: @$groupMembers
            }
          ]
      if overlay$
        z '.overlay',
          overlay$

      if selectedProfileDialogUser
        z @$profileDialog
