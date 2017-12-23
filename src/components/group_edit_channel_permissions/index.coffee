z = require 'zorium'
_map = require 'lodash/map'
_defaults = require 'lodash/defaults'
_find = require 'lodash/find'
RxReplaySubject = require('rxjs/ReplaySubject').ReplaySubject
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject
RxObservable = require('rxjs/Observable').Observable
require 'rxjs/add/observable/of'
require 'rxjs/add/operator/map'
require 'rxjs/add/operator/switch'

Icon = require '../icon'
ActionBar = require '../action_bar'
FlatButton = require '../flat_button'
PrimaryButton = require '../primary_button'
# PrimaryInput = require '../primary_input'
Dropdown = require '../dropdown'
Toggle = require '../toggle'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class GroupEditChannelPermissions
  constructor: ({@model, @router, group, conversation, gameKey}) ->
    me = @model.user.getMe()

    permissionTypes = [
      {
        key: 'readMessages'
      }
    ]

    roles = group.switchMap (group) =>
      @model.groupRole.getAllByGroupId group.id

    @roleValueStreams = new RxReplaySubject 1
    @roleValueStreams.next roles.map (roles) ->
      roles?[0]?.roleId

    groupAndRolesAndRoleId = RxObservable.combineLatest(
      group
      roles
      @roleValueStreams.switch()
      (vals...) -> vals
    )

    @$roleDropdown = new Dropdown {valueStreams: @roleValueStreams}
    @$cancelButton = new FlatButton()
    @$saveButton = new PrimaryButton()

    @state = z.state
      me: me
      isSaving: false
      group: group
      gameKey: gameKey
      conversation: conversation
      roles: roles
      permissionTypes: groupAndRolesAndRoleId.switchMap (response) =>
        [group, roles, roleId] = response
        role = _find roles, {roleId}
        @model.userGroupData.getMeByGroupId(group.id).map (data) ->
          _map permissionTypes, (type) ->
            isSelected = new RxBehaviorSubject(
              not data.globalBlockedNotifications?[type.key]
            )

            _defaults {
              $toggle: new Toggle {isSelected}
              isSelected: isSelected
            }, type

  save: =>
    {me, isSaving, group, conversation, gameKey} = @state.getValue()

    if isSaving
      return

    @state.set isSaving: true

    @model.conversation.updateById conversation.id, diff {
      groupId: group.id
    }
    .catch -> null
    .then (newConversation) =>
      conversation or= newConversation
      @state.set isSaving: false
      @router.go 'groupManageChannels', {gameKey, id: group.id}

  render: ({isNewChannel} = {}) =>
    {me, isSaving, group, roles, permissionTypes} = @state.getValue()

    z '.z-group-edit-channel-permissions',
      z '.g-grid',
        z @$roleDropdown,
          hintText: 'Type'
          isFloating: false
          options: _map roles, (role) ->
            {value: role.roleId, text: role.name}
        z 'ul.list',
          _map permissionTypes, ({key, $toggle, isSelected}) =>
            z 'li.item',
              z '.text', @model.l.get "permissions.#{key}"
              z '.toggle',
                z $toggle, {
                  onToggle: (isSelected) =>
                    null
                    # @model.userGroupData.updateMeByGroupId group.id, {
                    #   globalBlockedNotifications:
                    #     "#{key}": not isSelected
                    # }
                }
        z '.actions',
          z '.cancel-button',
            z @$cancelButton,
              isFullWidth: false
              text: @model.l.get 'general.cancel'
              onclick: =>
                @router.back()
          z '.save-button',
            z @$saveButton,
              isFullWidth: false
              text: if isSaving \
                    then @model.l.get 'general.loading'
                    else if isNewChannel
                    then @model.l.get 'general.create'
                    else @model.l.get 'general.save'
              onclick: =>
                @save isNewChannel
