z = require 'zorium'
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject

Dialog = require '../dialog'
PrimaryInput = require '../primary_input'
FlatButton = require '../flat_button'
Icon = require '../icon'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class JoinGroupDialog
  constructor: ({@model, @router, clan, @overlay$}) ->

    @clanPasswordValue = new RxBehaviorSubject ''
    @clanPasswordError = new RxBehaviorSubject null
    @$clanPasswordInput = new PrimaryInput
      value: @clanPasswordValue
      error: @clanPasswordError

    @$dialog = new Dialog()

    @state = z.state
      isLoading: false
      clan: clan
      error: null

  afterMount: ->
    ga? 'send', 'event', 'verify', 'join_group', 'mount'

  cancel: =>
    @overlay$.next null

  join: (e) =>
    e?.preventDefault()

    {clan} = @state.getValue()

    clanPassword = @clanPasswordValue.getValue()

    @state.set isLoading: true
    @model.clan.joinById clan?.id, {clanPassword}
    .then =>
      ga? 'send', 'event', 'verify', 'join_group', 'verified'
      @state.set isLoading: false, error: null
      @overlay$.next null
    .catch (err) =>
      @state.set
        error: @model.l.get 'joinGroupDialog.error'
        isLoading: false

  render: =>
    {step, isLoading, clan, error} = @state.getValue()

    z '.z-join-group-dialog',
      z @$dialog,
        onLeave: =>
          @overlay$.next null
        isVanilla: true
        $title: @model.l.get 'general.verify'
        $content:
          z '.z-join-group-dialog_dialog',
            z 'form.content', {
              onsubmit: @join
            },
              z '.error', error
              z '.input',
                z @$clanPasswordInput, {
                  type: 'text'
                  hintText: @model.l.get 'general.password'
                }
              z '.text', @model.l.get 'joinGroupDialog.text'
        cancelButton:
          text: @model.l.get 'general.cancel'
          onclick: @cancel
        submitButton:
          text: if isLoading then 'loading...' \
                else 'join'
          onclick: @join
