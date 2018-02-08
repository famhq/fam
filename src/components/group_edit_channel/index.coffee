z = require 'zorium'
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
PrimaryInput = require '../primary_input'
PrimaryTextarea = require '../primary_textarea'
Toggle = require '../toggle'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class GroupEditChannel
  constructor: ({@model, @router, group, conversation}) ->
    me = @model.user.getMe()

    @nameValueStreams = new RxReplaySubject 1
    @nameValueStreams.next (conversation?.map (conversation) ->
      conversation.data?.name) or RxObservable.of null
    @nameError = new RxBehaviorSubject null

    @descriptionValueStreams = new RxReplaySubject 1
    @descriptionValueStreams.next (conversation?.map (conversation) ->
      conversation.data?.description) or RxObservable.of null
    @descriptionError = new RxBehaviorSubject null

    @slowModeCooldownValueStreams = new RxReplaySubject 1
    @slowModeCooldownValueStreams.next (conversation?.map (conversation) ->
      conversation.data?.slowModeCooldown or '600') or RxObservable.of '600'
    @slowModeCooldownError = new RxBehaviorSubject null

    @$nameInput = new PrimaryInput
      valueStreams: @nameValueStreams
      error: @nameError

    @$descriptionTextarea = new PrimaryTextarea
      valueStreams: @descriptionValueStreams
      error: @descriptionError

    @$slowModeCooldownInput = new PrimaryInput
      valueStreams: @slowModeCooldownValueStreams
      error: @slowModeCooldownError

    @isSlowModeStreams = new RxReplaySubject 1
    @isSlowModeStreams.next (conversation?.map (conversation) ->
      conversation.data?.isSlowMode) or RxObservable.of null
    @$isSlowModeToggle = new Toggle {isSelectedStreams: @isSlowModeStreams}

    @$cancelButton = new FlatButton()
    @$saveButton = new PrimaryButton()

    @state = z.state
      me: me
      isSaving: false
      group: group
      conversation: conversation
      name: @nameValueStreams.switch()
      description: @descriptionValueStreams.switch()
      isSlowMode: @isSlowModeStreams.switch()
      slowModeCooldown: @slowModeCooldownValueStreams.switch()

  save: (isNewChannel) =>
    {me, isSaving, group, conversation, name, description,
      isSlowMode, slowModeCooldown} = @state.getValue()

    if isSaving
      return

    @state.set isSaving: true
    @nameError.next null

    fn = (diff) =>
      if isNewChannel
        @model.conversation.create diff
      else
        @model.conversation.updateById conversation.id, diff

    fn {
      name
      description
      isSlowMode
      slowModeCooldown
      groupId: group.id
    }
    .catch -> null
    .then (newConversation) =>
      conversation or= newConversation
      @state.set isSaving: false
      @router.go 'groupManageChannels', {groupId: group.key or group.id}

  render: ({isNewChannel} = {}) =>
    {me, isSaving, group, name, description, isSlowMode} = @state.getValue()

    z '.z-group-edit-channel',
      z '.g-grid',
        z '.input',
          z @$nameInput,
            hintText: @model.l.get 'groupEditChannel.nameInputHintText'

        z '.input',
          z @$descriptionTextarea,
            hintText: @model.l.get 'general.description'

        z '.input',
          z 'label.label',
            z '.text', 'Slow mode'
            @$isSlowModeToggle
        if isSlowMode
          z '.input',
            z @$slowModeCooldownInput,
              hintText: @model.l.get 'groupEditChannel.slowModeCooldownHintText'

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
