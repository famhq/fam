z = require 'zorium'
Rx = require 'rx-lite'
_ = require 'lodash'
_map = require 'lodash/collection/map'
_mapValues = require 'lodash/object/mapValues'
_isEmpty = require 'lodash/lang/isEmpty'

config = require '../../config'
colors = require '../../colors'
Head = require '../../components/head'
AppBar = require '../../components/app_bar'
ButtonBack = require '../../components/button_back'
GroupInfo = require '../../components/group_info'
GroupChat = require '../../components/group_chat'
GroupAnnouncements = require '../../components/group_announcements'
GroupMembers = require '../../components/group_members'
Tabs = require '../../components/tabs'
Icon = require '../../components/icon'
Spinner = require '../../components/spinner'

if window?
  require './index.styl'

module.exports = class GroupPage
  hideDrawer: true

  constructor: ({@model, requests, @router, serverData}) ->
    groupId = requests.map ({route}) ->
      route.params.id

    group = groupId.flatMapLatest (groupId) =>
      @model.group.getById groupId

    @$head = new Head({
      @model
      requests
      serverData
      meta: group.map (group) ->
        title: group.name
        description: group.name
    })
    @$appBar = new AppBar {@model}
    @$buttonBack = new ButtonBack {@model, @router}
    @$groupInfo = new GroupInfo {@model, @router, group}
    @$groupChat = new GroupChat {
      @model
      @router
      conversation: groupId.flatMapLatest (groupId) =>
        @model.conversation.getByGroupId groupId
    }
    @$groupAnnouncements = new GroupAnnouncements {@model, @router, group}
    @$groupMembers = new GroupMembers {@model, @router, group}
    @$tabs = new Tabs {@model}
    @$editIcon = new Icon()
    @$settingsIcon = new Icon()
    @$groupInfoIcon = new Icon()
    @$groupChatIcon = new Icon()
    @$groupAnnouncementsIcon = new Icon()
    @$groupMembersIcon = new Icon()

    @state = z.state {group}

  renderHead: => @$head

  render: =>
    {group} = @state.getValue()

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
              z @$editIcon,
                icon: 'edit'
                color: colors.$primary500
                onclick: =>
                  @router.go "/group/#{group?.id}/edit"

      }
      z @$tabs,
        isBarFixed: false
        barBgColor: colors.$tertiary700
        tabs: [
          {
            $menuIcon:
              z @$groupInfoIcon,
                icon: 'info'
                isTouchTarget: false
                color: colors.$white
            $menuText: 'Info'
            $el: @$groupInfo
          }
          {
            $menuIcon:
              z @$groupChatIcon,
                icon: 'chat-bubble'
                isTouchTarget: false
                color: colors.$white
            $menuText: 'Chat'
            $el: @$groupChat
          }
          {
            $menuIcon:
              z @$groupAnnouncementsIcon,
                icon: 'notifications'
                isTouchTarget: false
                color: colors.$white
            $menuText: 'Announcements'
            $el: @$groupAnnouncements
          }
          {
            $menuIcon:
              z @$groupMembersIcon,
                icon: 'friends'
                isTouchTarget: false
                color: colors.$white
            $menuText: 'Members'
            $el: @$groupMembers
          }
        ]
