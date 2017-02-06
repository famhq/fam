z = require 'zorium'
Rx = require 'rx-lite'
_map = require 'lodash/map'

Icon = require '../icon'
ChannelList = require '../channel_list'
GroupBadge = require '../group_badge'
colors = require '../../colors'

if window?
  require './index.styl'

DRAWER_RIGHT_PADDING = 56
DRAWER_MAX_WIDTH = 336

module.exports = class ChannelDrawer
  constructor: ({@model, @router, @isOpen, group, conversation}) ->
    me = @model.user.getMe()

    @$channelList = new ChannelList {@model, @router, group}
    @$chatIcon = new Icon()
    @$membersIcon = new Icon()
    @$settingsIcon = new Icon()
    @$manageChannelsSettingsIcon = new Icon()
    @$editIcon = new Icon()

    @$groupBadge = new GroupBadge {@model, group}

    @state = z.state
      isOpen: @isOpen
      group: group
      conversation: conversation
      me: @model.user.getMe()

  render: =>
    {isOpen, group, me, conversation} = @state.getValue()

    drawerWidth = Math.min \
      window?.innerWidth - DRAWER_RIGHT_PADDING, DRAWER_MAX_WIDTH
    translateX = if isOpen then '0' else "-#{drawerWidth}px"

    hasAdminPermission = @model.group.hasPermission group, me, {level: 'admin'}

    z '.z-channel-drawer', {
      className: z.classKebab {isOpen}
    },
      z '.group-name',
        z '.badge', z @$groupBadge
        z '.name', group?.name

      z '.divider'

      z '.menu',
        z @$chatIcon,
          icon: 'chat'
          color: colors.$primary500
          onclick: =>
            @isOpen.onNext false
            @router.go "/group/#{group.id}/chat"
        z @$membersIcon,
          icon: 'friends'
          color: colors.$primary500
          onclick: =>
            @isOpen.onNext false
            @router.go "/group/#{group.id}/members"
        z @$settingsIcon,
          icon: 'settings'
          color: colors.$primary500
          onclick: =>
            @isOpen.onNext false
            @router.go "/group/#{group.id}/settings"
        if hasAdminPermission
          z @$editIcon,
            icon: 'edit'
            color: colors.$primary500
            onclick: =>
              @isOpen.onNext false
              @router.go "/group/#{group.id}/edit"

      z '.divider'

      z @$channelList, {
        selectedConversationId: conversation?.id
        onclick: (e, {id}) =>
          @router.go "/group/#{group?.id}/chat/#{id}", {
            ignoreHistory: true
          }
          @isOpen.onNext false
      }

      if hasAdminPermission
        [
          z '.divider'
          z '.manage-channels', {
            onclick: =>
              @router.go "/group/#{group?.id}/manageChannels"
          },
            z '.icon',
              z @$manageChannelsSettingsIcon,
                icon: 'settings'
                isTouchTarget: false
                color: colors.$primary500
            z '.text', 'Manage channels'
        ]
