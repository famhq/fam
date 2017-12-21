z = require 'zorium'
_map = require 'lodash/map'
_defaults = require 'lodash/defaults'
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject
RxReplaySubject = require('rxjs/ReplaySubject').ReplaySubject
RxObservable = require('rxjs/Observable').Observable
require 'rxjs/add/observable/of'
require 'rxjs/add/operator/map'
require 'rxjs/add/operator/switchMap'
require 'rxjs/add/operator/switch'

Toggle = require '../toggle'
PrimaryInput = require '../primary_input'
PrimaryButton = require '../primary_button'
PrimaryTextarea = require '../primary_textarea'
Icon = require '../icon'
config = require '../../config'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class GroupSettings
  constructor: ({@model, @router, group, gameKey}) ->
    me = @model.user.getMe()
    @nameValueStreams = new RxReplaySubject 1
    @nameValueStreams.next (group?.map (group) ->
      group.name) or RxObservable.of null
    @nameError = new RxBehaviorSubject null

    @descriptionValueStreams = new RxReplaySubject 1
    @descriptionValueStreams.next (group?.map (group) ->
      group.description) or RxObservable.of null
    @descriptionError = new RxBehaviorSubject null

    @passwordValueStreams = new RxReplaySubject 1
    @passwordValueStreams.next (group?.map (group) ->
      group.password) or RxObservable.of null
    @passwordError = new RxBehaviorSubject null

    @moderatorUsernameValue = new RxBehaviorSubject ''
    @moderatorUsernameError = new RxBehaviorSubject null

    @isPrivateStreams = new RxReplaySubject 1
    @isPrivateStreams.next (group?.map (group) ->
      group.privacy is 'private') or RxObservable.of null

    @$manageRecordsIcon = new Icon()

    @$nameInput = new PrimaryInput
      valueStreams: @nameValueStreams
      error: @nameError

    @$descriptionTextarea = new PrimaryTextarea
      valueStreams: @descriptionValueStreams
      error: @descriptionError

    @$passwordInput = new PrimaryInput
      valueStreams: @passwordValueStreams
      error: @passwordError

    @$moderatorUsernameInput = new PrimaryInput
      value: @moderatorUsernameValue
      error: @moderatorUsernameError

    @$moderatorUsernameButton = new PrimaryButton()

    @$isPrivateToggle = new Toggle {isSelectedStreams: @isPrivateStreams}

    @state = z.state
      me: me
      group: group
      gameKey: gameKey
      isSaving: false
      isLeaveGroupLoading: false
      name: @nameValueStreams.switch()
      description: @descriptionValueStreams.switch()
      password: @passwordValueStreams.switch()
      isPrivate: @isPrivateStreams.switch()

  save: =>
    {group, name, description, password, gameKey,
      isPrivate, isSaving} = @state.getValue()

    if isSaving
      return

    @state.set isSaving: true
    @passwordError.next null

    @model.group.updateById group.id, {name, description, password, isPrivate}
    .then =>
      @state.set isSaving: false
      @router.go 'groupChat', {gameKey, id: group.id}

  render: =>
    {me, group, isSaving, gameKey,
      isPrivate} = @state.getValue()

    items = []

    hasAdminPermission = @model.group.hasPermission group, me, {level: 'admin'}

    if hasAdminPermission
      items = items.concat [
        {
          $icon: @$manageRecordsIcon
          icon: 'edit'
          text: 'Manage Records'
          onclick: =>
            @router.go 'groupManageRecords', {gameKey}
        }
      ]

    z '.z-group-settings',
      z '.g-grid',
        z '.title', @model.l.get 'general.general'

        if hasAdminPermission
          [
            z '.input',
              z @$nameInput,
                hintText: @model.l.get 'claimClanDialog.groupNameHintText'

            z '.input',
              z @$descriptionTextarea,
                hintText: @model.l.get 'general.description'

            if isPrivate
              z '.input',
                z @$passwordInput,
                  hintText: @model.l.get 'groupSettings.passwordToJoin'
          ]

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

        if me?.username is 'austin' # TODO
          z '.input',
            z @$moderatorUsernameInput,
              hintText: 'Add mod by username'
            z @$moderatorUsernameButton,
              text: 'Add'
              onclick: =>
                @model.groupUser.createModeratorByUsername {
                  username: @moderatorUsernameValue.getValue()
                  groupId: group.id
                  roleId: null
                }
