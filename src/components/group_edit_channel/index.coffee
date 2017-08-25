z = require 'zorium'
Rx = require 'rx-lite'

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
  constructor: ({@model, @router, group, conversation}) ->
    me = @model.user.getMe()

    @nameValueStreams = new Rx.ReplaySubject 1
    @nameValueStreams.onNext (conversation?.map (conversation) ->
      conversation.name) or Rx.Observable.just null
    @nameError = new Rx.BehaviorSubject null

    @descriptionValueStreams = new Rx.ReplaySubject 1
    @descriptionValueStreams.onNext (conversation?.map (conversation) ->
      conversation.description) or Rx.Observable.just null
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
      conversation: conversation
      name: @nameValueStreams.switch()
      description: @descriptionValueStreams.switch()

  save: (isNewChannel) =>
    {me, isSaving, group, conversation, name, description} = @state.getValue()

    if isSaving
      return

    @state.set isSaving: true
    @nameError.onNext null

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
      @router.go "/group/#{group.id}/manage-channels"

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
