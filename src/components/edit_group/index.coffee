_ = require 'lodash'
z = require 'zorium'
log = require 'loga'
Rx = require 'rx-lite'
Button = require 'zorium-paper/button'

Icon = require '../icon'
EditGroupChangeBadge = require '../edit_group_change_badge'
GroupHeader = require '../group_header'
PrimaryButton = require '../primary_button'
PrimaryInput = require '../primary_input'
PrimaryTextarea = require '../primary_textarea'
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class EditGroup
  constructor: ({@model, @router, group}) ->
    me = @model.user.getMe()

    @badge = new Rx.BehaviorSubject null

    @nameValue = new Rx.BehaviorSubject ''
    @nameError = new Rx.BehaviorSubject null

    @descriptionValue = new Rx.BehaviorSubject ''
    @descriptionError = new Rx.BehaviorSubject null

    @selectedBadgeStreams = new Rx.ReplaySubject 1
    @selectedBadgeStreams.onNext (@group?.map (group) ->
      group.badgeId) or Rx.Observable.just null

    @selectedBackgroundStreams = new Rx.ReplaySubject 1
    @selectedBackgroundStreams.onNext (@group?.map (group) ->
      group.background) or Rx.Observable.just null

    # TODO: better way to do this? get zorium-paper to accept stream of streams
    group?.take(1).subscribe (group) =>
      @badge.onNext group?.badge
      @nameValue.onNext group?.name
      @descriptionValue.onNext group?.description

    @$groupHeader = new GroupHeader {group}
    @$discardIcon = new Icon()
    @$doneIcon = new Icon()

    @$editGroupChangeBadge = new EditGroupChangeBadge {
      @model
      @router
      group
      @selectedBadgeStreams
      @selectedBackgroundStreams
    }

    @$changeBadgeButton = new PrimaryButton()

    @$nameInput = new PrimaryInput
      value: @nameValue
      error: @nameError

    @$descriptionTextarea = new PrimaryTextarea
      value: @descriptionValue
      error: @descriptionError

    @state = z.state
      me: me
      isSaving: false
      group: group
      selectedBadge: @selectedBadgeStreams.switch()
      selectedBackground: @selectedBackgroundStreams.switch()

  beforeUnmount: =>
    @selectedBadgeStreams.onNext @group?.map (group) ->
      group.badgeId
    @selectedBackgroundStreams.onNext @group?.map (group) ->
      group.background

  save: (isNewGroup) =>
    {selectedBackground, selectedBadge, me, isSaving, group} = @state.getValue()

    if isSaving
      return

    @state.set isSaving: true
    @nameError.onNext null

    name = @nameValue.getValue()
    description = @descriptionValue.getValue()
    badge = @badge.getValue()

    fn = (diff) =>
      if isNewGroup
        @model.group.create diff
      else
        @model.group.updateById group.id, diff

    fn {
      name
      description
      badge
      background: selectedBackground
      badgeId: selectedBadge
    }
    .catch -> null
    .then (newGroup) =>
      group or= newGroup
      @state.set isSaving: false
      @router.go "/group/#{group.id}"

  render: ({isNewGroup} = {}) =>
    {me, isSaving, isChangingBadge,
      selectedBadge, selectedBackground} = @state.getValue()

    z '.z-edit-group',
      if isChangingBadge
        z @$editGroupChangeBadge, {
          onBack: =>
            @state.set isChangingBadge: false
        }
      else [
        z '.actions',
          z '.action', {
            onclick: =>
              @router.back()
          },
            z '.icon',
              z @$discardIcon,
                icon: 'close'
                color: colors.$primary500
                isTouchTarget: false
            z '.text', 'Cancel'
          z '.action', {
            onclick: =>
              @save isNewGroup
          },
            z '.icon',
              z @$doneIcon,
                icon: 'check'
                color: colors.$primary500
                isTouchTarget: false
            z '.text',
              if isSaving
              then 'Loading...'
              else if isNewGroup then 'Create'
              else 'Save'

        z @$groupHeader, {
          badgeId: selectedBadge
          background: selectedBackground
        }
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
      ]
