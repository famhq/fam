z = require 'zorium'
Rx = require 'rx-lite'

Icon = require '../icon'
ActionBar = require '../action_bar'
EditGroupChangeBadge = require '../edit_group_change_badge'
GroupHeader = require '../group_header'
PrimaryButton = require '../primary_button'
PrimaryInput = require '../primary_input'
PrimaryTextarea = require '../primary_textarea'
Toggle = require '../toggle'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class EditGroup
  constructor: ({@model, @router, @group}) ->
    me = @model.user.getMe()

    @nameValueStreams = new Rx.ReplaySubject 1
    @nameValueStreams.onNext (@group?.map (group) ->
      group.name) or Rx.Observable.just null
    @nameError = new Rx.BehaviorSubject null

    @descriptionValueStreams = new Rx.ReplaySubject 1
    @descriptionValueStreams.onNext (@group?.map (group) ->
      group.description) or Rx.Observable.just null
    @descriptionError = new Rx.BehaviorSubject null

    @selectedBadgeStreams = new Rx.ReplaySubject 1
    @selectedBadgeStreams.onNext (@group?.map (group) ->
      group.badgeId) or Rx.Observable.just null

    @selectedBackgroundStreams = new Rx.ReplaySubject 1
    @selectedBackgroundStreams.onNext (@group?.map (group) ->
      group.background) or Rx.Observable.just null

    @isPrivateStreams = new Rx.ReplaySubject 1
    @isPrivateStreams.onNext (@group?.map (group) ->
      group.mode is 'private') or Rx.Observable.just null

    @$isPrivateToggle = new Toggle {isSelectedStreams: @isPrivateStreams}

    @$actionBar = new ActionBar {@model}
    @$groupHeader = new GroupHeader {@group}

    @$editGroupChangeBadge = new EditGroupChangeBadge {
      @model
      @router
      @group
      @selectedBadgeStreams
      @selectedBackgroundStreams
    }

    @$changeBadgeButton = new PrimaryButton()

    @$nameInput = new PrimaryInput
      valueStreams: @nameValueStreams
      error: @nameError

    @$descriptionTextarea = new PrimaryTextarea
      valueStreams: @descriptionValueStreams
      error: @descriptionError

    @state = z.state
      me: me
      isSaving: false
      group: @group
      name: @nameValueStreams.switch()
      isPrivate: @isPrivateStreams.switch()
      description: @descriptionValueStreams.switch()
      selectedBadge: @selectedBadgeStreams.switch()
      selectedBackground: @selectedBackgroundStreams.switch()

  beforeUnmount: =>
    if @group
      @selectedBadgeStreams.onNext @group?.map (group) ->
        group.badgeId
      @selectedBackgroundStreams.onNext @group?.map (group) ->
        group.background

  save: (isNewGroup) =>
    {selectedBackground, selectedBadge, me, isSaving, group, isPrivate,
      name, description} = @state.getValue()

    if isSaving
      return

    @state.set isSaving: true
    @nameError.onNext null

    fn = (diff) =>
      if isNewGroup
        @model.group.create diff
      else
        @model.group.updateById group.id, diff

    fn {
      name
      description
      mode: if isPrivate then 'private' else 'open'
      background: selectedBackground
      badgeId: selectedBadge
    }
    .catch -> null
    .then (newGroup) =>
      group or= newGroup
      @state.set isSaving: false
      @router.go "/group/#{group.id}/chat"

  render: ({isNewGroup} = {}) =>
    {me, isSaving, isChangingBadge, group, name, description,
      selectedBadge, selectedBackground} = @state.getValue()

    z '.z-edit-group',
      if isChangingBadge
        z @$editGroupChangeBadge, {
          onBack: =>
            @state.set isChangingBadge: false
        }
      else [
        z @$actionBar, {
          isSaving
          cancel:
            onclick: =>
              @router.back()
          save:
            text: if isNewGroup \
                  then @model.l.get 'general.create'
                  else @model.l.get 'general.save'
            onclick: =>
              @save isNewGroup
        }
        z @$groupHeader, {
          badgeId: selectedBadge
          background: selectedBackground
        }
        z '.g-grid',
          z '.content',
            z '.button',
              z @$changeBadgeButton,
                text: 'Change group badge'
                onclick: =>
                  @state.set isChangingBadge: true

            z '.input',
              z @$nameInput,
                hintText: 'Group name'

            z '.input',
              z @$descriptionTextarea,
                hintText: 'Description'

            z '.label',
              'Private (invite-only)'
              z '.right',
                @$isPrivateToggle
      ]
