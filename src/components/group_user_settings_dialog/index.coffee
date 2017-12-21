z = require 'zorium'
_map = require 'lodash/map'
_defaults = require 'lodash/defaults'
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject
RxObservable = require('rxjs/Observable').Observable
require 'rxjs/add/operator/map'
require 'rxjs/add/operator/switchMap'

Toggle = require '../toggle'
Dialog = require '../dialog'
Icon = require '../icon'
config = require '../../config'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class GroupUserSettingsDialog
  constructor: ({@model, @router, group, gameKey, @overlay$}) ->
    notificationTypes = [
      {
        name: @model.l.get 'groupSettings.chatMessage'
        key: 'chatMessage'
      }
      # {
      #   name: 'New announcments'
      #   key: 'announcement'
      # }
    ]

    me = @model.user.getMe()
    @$leaveIcon = new Icon()
    @$dialog = new Dialog()

    @state = z.state
      me: me
      group: group
      gameKey: gameKey
      isSaving: false
      isLeaveGroupLoading: false
      notificationTypes: group.switchMap (group) =>
        @model.userGroupData.getMeByGroupId(group.id).map (data) ->
          _map notificationTypes, (type) ->
            isSelected = new RxBehaviorSubject(
              not data.globalBlockedNotifications?[type.key]
            )

            _defaults {
              $toggle: new Toggle {isSelected}
              isSelected: isSelected
            }, type

  leaveGroup: =>
    {isLeaveGroupLoading, group, gameKey} = @state.getValue()

    unless isLeaveGroupLoading
      @state.set isLeaveGroupLoading: true
      @model.group.leaveById group.id
      .then =>
        @state.set isLeaveGroupLoading: false
        @router.go 'chat', {gameKey}
        @overlay$.next null

  render: =>
    {me, notificationTypes, group, isLeaveGroupLoading, isSaving, gameKey,
      } = @state.getValue()

    items = []

    hasAdminPermission = @model.group.hasPermission group, me, {level: 'admin'}
    unless hasAdminPermission
      items = items.concat [
        {
          $icon: @$leaveIcon
          icon: 'subtract-circle'
          text: if isLeaveGroupLoading \
                then @model.l.get 'general.loading'
                else @model.l.get 'groupSettings.leaveGroup'
          onclick: @leaveGroup
        }
      ]

    z '.z-group-user-settings-dialog',
      z @$dialog,
        isVanilla: true
        onLeave: =>
          @overlay$.next null
        # $title: @model.l.get 'general.filter'
        $content:
          z '.z-group-user-settings-dialog_dialog',
            z 'ul.list',
              if hasAdminPermission
                z 'li.item',
                  z '.text', 'Private (password required)'
                  z '.toggle',
                    @$isPrivateToggle

              _map items, ({$icon, icon, text, onclick}) ->
                z 'li.item', {onclick},
                  z '.icon',
                    z $icon,
                      icon: icon
                      isTouchTarget: false
                      color: colors.$primary500
                  z '.text', text
            z '.title', @model.l.get 'general.notifications'
            z 'ul.list',
              _map notificationTypes, ({name, key, $toggle, isSelected}) =>
                z 'li.item',
                  z '.text', name
                  z '.toggle',
                    z $toggle, {
                      onToggle: (isSelected) =>
                        @model.userGroupData.updateMeByGroupId group.id, {
                          globalBlockedNotifications:
                            "#{key}": not isSelected
                        }
                    }

        cancelButton:
          text: @model.l.get 'general.close'
          onclick: =>
            @overlay$.next null
