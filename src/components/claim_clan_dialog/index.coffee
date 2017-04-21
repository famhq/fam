z = require 'zorium'
Rx = require 'rx-lite'

Dialog = require '../dialog'
PrimaryInput = require '../primary_input'
FlatButton = require '../flat_button'
Icon = require '../icon'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class ClaimClanDialog
  constructor: ({@model, @router, @isVisible, clan}) ->

    @groupNameValue = new Rx.BehaviorSubject ''
    @groupNameError = new Rx.BehaviorSubject null
    @$groupNameInput = new PrimaryInput
      value: @groupNameValue
      error: @groupNameError

    @clanPasswordValue = new Rx.BehaviorSubject ''
    @clanPasswordError = new Rx.BehaviorSubject null
    @$clanPasswordInput = new PrimaryInput
      value: @clanPasswordValue
      error: @clanPasswordError

    @$dialog = new Dialog()
    @$chatIcon = new Icon()

    @state = z.state
      step: 'claim'
      isLoading: false
      clan: clan
      error: null

  cancel: =>
    @isVisible.onNext false

  claim: (e) =>
    e?.preventDefault()
    {clan} = @state.getValue()

    @state.set isLoading: true
    @model.clan.claimById clan?.id
    .then =>
      @state.set isLoading: false, step: 'createGroup', error: null
    .catch (err) =>
      @state.set error: 'Unable to verify', isLoading: false

  createGroup: (e) =>
    e?.preventDefault()
    {clan} = @state.getValue()

    groupName = @groupNameValue.getValue()
    clanPassword = @clanPasswordValue.getValue()

    @state.set isLoading: true
    @model.clan.createGroupById clan?.id, {groupName, clanPassword}
    .then =>
      @state.set isLoading: false, error: null
      @isVisible.onNext false
    .catch (err) =>
      @state.set error: err

  render: =>
    {step, isLoading, clan, error} = @state.getValue()

    z '.z-claim-clan-dialog',
      z @$dialog,
        onLeave: =>
          @isVisible.onNext false
        isVanilla: true
        $title: 'Claim clan'
        $content:
          z '.z-claim-clan-dialog_dialog',
            if step is 'createGroup'
              z 'form.content', {
                onsubmit: if step is 'createGroup' then @createGroup else @claim
              },
                if error
                  z '.error', error
                z '.input',
                  z @$groupNameInput, {
                    hintText: 'Group name'
                  }
                z '.input',
                  z @$clanPasswordInput, {
                    type: 'text'
                    hintText: 'Password'
                  }
            else
              z '.content',
                if error
                  z '.error', error
                z '.text',
                  'Add this code to your clan description in the game to verify
                  your ownership'
                z '.code', clan?.code
                z '.text', 'Claiming ownership will unlock:'
                z '.unlock',
                  z '.icon',
                    z @$chatIcon,
                      icon: 'chat'
                      isTouchTarget: false
                      color: colors.$primary500
                  'Private clan chat'
        cancelButton:
          text: 'cancel'
          onclick: @cancel
        submitButton:
          text: if isLoading then 'loading...' \
                else if step is 'createGroup' then 'finish'
                else 'claim'
          onclick: if step is 'createGroup' then @createGroup else @claim
