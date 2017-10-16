z = require 'zorium'
Rx = require 'rxjs'

Icon = require '../icon'
ActionBar = require '../action_bar'
PrimaryButton = require '../primary_button'
PrimaryInput = require '../primary_input'
PrimaryTextarea = require '../primary_textarea'
Toggle = require '../toggle'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class GroupEditChannel
  constructor: ({@model, @router, group, conversation, gameKey}) ->
    me = @model.user.getMe()

    @nameValueStreams = new Rx.ReplaySubject 1
    @nameValueStreams.next (conversation?.map (conversation) ->
      conversation.name) or Rx.Observable.of null
    @nameError = new Rx.BehaviorSubject null

    @descriptionValueStreams = new Rx.ReplaySubject 1
    @descriptionValueStreams.next (conversation?.map (conversation) ->
      conversation.description) or Rx.Observable.of null
    @descriptionError = new Rx.BehaviorSubject null

    @$actionBar = new ActionBar {@model}

    @$nameInput = new PrimaryInput
      valueStreams: @nameValueStreams
      error: @nameError

    @$descriptionTextarea = new PrimaryTextarea
      valueStreams: @descriptionValueStreams
      error: @descriptionError

    @state = z.state
      me: me
      isSaving: false
      group: group
      gameKey: gameKey
      conversation: conversation
      name: @nameValueStreams.switch()
      description: @descriptionValueStreams.switch()

  save: (isNewChannel) =>
    {me, isSaving, group, conversation, name,
      gameKey, description} = @state.getValue()

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
      groupId: group.id
    }
    .catch -> null
    .then (newConversation) =>
      conversation or= newConversation
      @state.set isSaving: false
      @router.go 'groupManageChannels', {gameKey, id: group.id}

  render: ({isNewChannel} = {}) =>
    {me, isSaving, group, name, description} = @state.getValue()

    z '.z-group-edit-channel',
      z @$actionBar, {
        isSaving
        cancel:
          onclick: =>
            @router.back()
        save:
          text: if isNewChannel \
                then @model.l.get 'general.create'
                else @model.l.get 'general.save'
          onclick: =>
            @save isNewChannel
      }
      z '.content',
        z '.input',
          z @$nameInput,
            hintText: @model.l.get 'groupEditChannel.nameInputHintText'

        z '.input',
          z @$descriptionTextarea,
            hintText: @model.l.get 'general.description'
