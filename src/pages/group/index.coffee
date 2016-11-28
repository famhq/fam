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
  constructor: ({@model, requests, @router, serverData}) ->
    group = requests.flatMapLatest ({route}) =>
      @model.group.getById route.params.id

    @$head = new Head({
      @model
      requests
      serverData
      meta: {
        title: 'Group'
        description: 'Group'
      }
    })
    @$appBar = new AppBar {@model}
    @$buttonBack = new ButtonBack {@model}
    @$groupInfo = new GroupInfo {@model, @router}
    @$groupChat = new GroupChat {@model, @router}
    @$groupAnnouncements = new GroupAnnouncements {@model, @router}
    @$groupMembers = new GroupMembers {@model, @router}
    @$tabs = new Tabs {@model}
    @$groupInfoIcon = new Icon()
    @$groupChatIcon = new Icon()
    @$groupAnnouncementsIcon = new Icon()
    @$groupMembersIcon = new Icon()

  renderHead: => @$head

  render: =>
    z '.p-group', {
      style:
        height: "#{window?.innerHeight}px"
    },
      z @$appBar, {
        title: 'Group'
        isFlat: true
        $topLeftButton: z @$buttonBack, {color: colors.$tertiary900}
      }
      z @$tabs,
        isBarFixed: false
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
