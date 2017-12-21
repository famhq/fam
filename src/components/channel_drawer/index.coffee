z = require 'zorium'
_map = require 'lodash/map'

Icon = require '../icon'
ChannelList = require '../channel_list'
colors = require '../../colors'

if window?
  require './index.styl'

DRAWER_RIGHT_PADDING = 56
DRAWER_MAX_WIDTH = 336

module.exports = class ChannelDrawer
  constructor: ({@model, @router, @isOpen, group, conversation, gameKey}) ->
    me = @model.user.getMe()

    @$channelList = new ChannelList {@model, @router, group}
    @$manageChannelsSettingsIcon = new Icon()

    @state = z.state
      isOpen: @isOpen
      group: group
      conversation: conversation
      gameKey: gameKey
      me: @model.user.getMe()

  render: =>
    {isOpen, group, gameKey, me, conversation} = @state.getValue()

    hasAdminPermission = @model.group.hasPermission group, me, {level: 'admin'}

    z '.z-channel-drawer', {
      onclick: =>
        @isOpen.next false
    },
      z '.drawer', {
        onclick: (e) ->
          e?.stopPropagation()
      },
        z '.title', @model.l.get 'channelDrawer.title'

        z @$channelList, {
          selectedConversationId: conversation?.id
          onclick: (e, {id}) =>
            @router.go 'groupChatConversation', {
              gameKey, id: group?.id, conversationId: id
            }, {ignoreHistory: true}
            @isOpen.next false
        }

        if hasAdminPermission
          [
            z '.divider'
            z '.manage-channels', {
              onclick: =>
                @router.go 'groupManageChannels', {gameKey, id: group?.id}
            },
              z '.icon',
                z @$manageChannelsSettingsIcon,
                  icon: 'settings'
                  isTouchTarget: false
                  color: colors.$primary500
              z '.text', 'Manage channels'
          ]
