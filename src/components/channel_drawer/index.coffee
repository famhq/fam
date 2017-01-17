z = require 'zorium'
Rx = require 'rx-lite'
_map = require 'lodash/map'

Icon = require '../icon'
ChannelList = require '../channel_list'
colors = require '../../colors'

if window?
  require './index.styl'

DRAWER_RIGHT_PADDING = 56
DRAWER_MAX_WIDTH = 336

module.exports = class ChannelDrawer
  constructor: ({@model, @router, @isOpen, group, conversation}) ->
    me = @model.user.getMe()

    @$channelList = new ChannelList {@model, @router, group}
    @$settingsIcon = new Icon()

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
      style:
        display: if window? then 'block' else 'none'
    },
      z '.overlay', {
        onclick: (e) =>
          e?.preventDefault()
          @isOpen.onNext false
      }

      z '.drawer', {
        style:
          width: "#{drawerWidth}px"
          transform: "translate(#{translateX}, 0)"
          webkitTransform: "translate(#{translateX}, 0)"
      },
        z '.title', 'Chat channels'
        z @$channelList, {
          selectedConversationId: conversation?.id
          onclick: (e, {id}) =>
            @router.go "/group/#{group?.id}/channel/#{id}", {
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
                z @$settingsIcon,
                  icon: 'settings'
                  isTouchTarget: false
                  color: colors.$primary500
              z '.text', 'Manage channels'
          ]
