z = require 'zorium'
Rx = require 'rx-lite'
_map = require 'lodash/map'
_defaults = require 'lodash/defaults'

Toggle = require '../toggle'
Icon = require '../icon'
config = require '../../config'
colors = require '../../colors'

if window?
  require './index.styl'

NOTIFICATION_TYPES = [
  {
    name: 'New chat messages'
    key: 'messages'
  }
  {
    name: 'New announcments'
    key: 'announcements'
  }
]
module.exports = class Settings
  constructor: ({@model, @portal, @router, group}) ->
    me = @model.user.getMe()

    @$leaveIcon = new Icon()

    @state = z.state
      me: me
      group: group
      isLeaveGroupLoading: false
      notificationTypes: me.map (me) ->
        _map NOTIFICATION_TYPES, (type) ->
          isSelected = new Rx.BehaviorSubject(
            not me.flags.blockedNotifications?[type.key]
          )

          _defaults {
            $toggle: new Toggle {isSelected}
            isSelected: isSelected
          }, type

  render: =>
    {me, notificationTypes, group, isLeaveGroupLoading} = @state.getValue()

    z '.z-group-settings',
      z '.g-grid',
        z '.title', 'General'
        z 'ul.list',
          z 'li.item', {
            onclick: =>
              unless isLeaveGroupLoading
                @state.set isLeaveGroupLoading: true
                @model.group.leaveById group.id
                .then =>
                  @state.set isLeaveGroupLoading: false
                  @router.go '/community'
          },
            z '.icon',
              z @$leaveIcon,
                icon: 'subtract-circle'
                isTouchTarget: false
                color: colors.$primary500
            z '.text', if isLeaveGroupLoading \
                       then 'Loading'
                       else 'Leave group'

        # z '.title', 'Notifications'
        # z 'ul.list',
        #   _map notificationTypes, ({name, key, $toggle, isSelected}) =>
        #     z 'li.item',
        #       z '.text', name
        #       z '.toggle',
        #         z $toggle, {
        #           onToggle: (isSelected) =>
        #             @model.user.update {
        #               flags:
        #                 blockedNotifications:
        #                   "#{key}": not isSelected
        #             }
        #         }
