z = require 'zorium'
Rx = require 'rx-lite'

Dialog = require '../dialog'
PrimaryInput = require '../primary_input'
FlatButton = require '../flat_button'
Icon = require '../icon'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class JoinGroupDialog
  constructor: ({@model, @router, @isVisible, clan}) ->

    @clanPasswordValue = new Rx.BehaviorSubject ''
    @clanPasswordError = new Rx.BehaviorSubject null
    @$clanPasswordInput = new PrimaryInput
      value: @clanPasswordValue
      error: @clanPasswordError

    @$dialog = new Dialog()

    @state = z.state
      isLoading: false
      clan: clan
      error: null

  cancel: =>
    @isVisible.onNext false

  join: (e) =>
    e?.preventDefault()

    {clan} = @state.getValue()

    clanPassword = @clanPasswordValue.getValue()

    @state.set isLoading: true
    @model.clan.joinById clan?.id, {clanPassword}
    .then =>
      @state.set isLoading: false, error: null
      @isVisible.onNext false
    .catch (err) =>
      @state.set error: 'Incorrect password', isLoading: false

  render: =>
    {step, isLoading, clan, error} = @state.getValue()

    z '.z-join-group-dialog',
      z @$dialog,
        onLeave: =>
          @isVisible.onNext false
        isVanilla: true
        $title: 'Join group'
        $content:
          z '.z-join-group-dialog_dialog',
            z 'form.content', {
              onsubmit: @join
            },
              z '.error', error
              z '.input',
                z @$clanPasswordInput, {
                  type: 'text'
                  hintText: 'Password'
                }
              z '.text', 'Ask your clan leader for the group password to join'
        cancelButton:
          text: 'cancel'
          onclick: @cancel
        submitButton:
          text: if isLoading then 'loading...' \
                else 'join'
          onclick: @join
