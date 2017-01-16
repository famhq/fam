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
    key: 'chatMessage'
  }
  # {
  #   name: 'New announcments'
  #   key: 'announcement'
  # }
]
module.exports = class Settings
  constructor: ({@model, @portal, @router, group}) ->
    me = @model.user.getMe()

    @$leaveIcon = new Icon()
    @$manageRecordsIcon = new Icon()

    @state = z.state
      me: me
      group: group
      isLeaveGroupLoading: false
      notificationTypes: group.flatMapLatest (group) =>
        @model.groupUserData.getMeByGroupId(group.id).map (data) ->
          _map NOTIFICATION_TYPES, (type) ->
            isSelected = new Rx.BehaviorSubject(
              not data.globalBlockedNotifications?[type.key]
            )

            _defaults {
              $toggle: new Toggle {isSelected}
              isSelected: isSelected
            }, type

  leaveGroup: =>
    {isLeaveGroupLoading, group} = @state.getValue()

    unless isLeaveGroupLoading
      @state.set isLeaveGroupLoading: true
      @model.group.leaveById group.id
      .then =>
        @state.set isLeaveGroupLoading: false
        @router.go '/community'

  render: =>
    {me, notificationTypes, group, isLeaveGroupLoading} = @state.getValue()

    items = [
      {
        $icon: @$leaveIcon
        icon: 'subtract-circle'
        text: if isLeaveGroupLoading \
              then 'Loading'
              else 'Leave group'
        onclick: @leaveGroup
      }
    ]

    hasAdminPermission = @model.group.hasPermission group, me, {level: 'admin'}
    if hasAdminPermission
      items = items.concat [
        {
          $icon: @$manageRecordsIcon
          icon: 'edit'
          text: 'Manage Records'
          onclick: =>
            @router.go "/group/#{group?.id}/manageRecords"
        }
      ]

    z '.z-group-settings',
      z '.g-grid',
        z '.title', 'General'
        z 'ul.list',
          _map items, ({$icon, icon, text, onclick}) ->
            z 'li.item', {onclick},
              z '.icon',
                z $icon,
                  icon: icon
                  isTouchTarget: false
                  color: colors.$primary500
              z '.text', text
        z '.title', 'Notifications'
        z 'ul.list',
          _map notificationTypes, ({name, key, $toggle, isSelected}) =>
            z 'li.item',
              z '.text', name
              z '.toggle',
                z $toggle, {
                  onToggle: (isSelected) =>
                    @model.groupUserData.updateMeByGroupId group.id, {
                      globalBlockedNotifications:
                        "#{key}": not isSelected
                    }
                }
