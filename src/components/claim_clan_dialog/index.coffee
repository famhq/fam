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
        $title: @model.l.get 'claimClanDialog.title'
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
                    hintText: @model.l.get 'claimClanDialog.groupNameHintText'
                  }
                z '.input',
                  z @$clanPasswordInput, {
                    type: 'text'
                    hintText: @model.l.get 'general.password'
                  }
            else
              z '.content',
                if error
                  z '.error', error
                z '.text',
                  @model.l.get 'claimClanDialog.text1'
                z '.code', clan?.code
                z '.text', @model.l.get 'claimClanDialog.text2'
                z '.unlock',
                  z '.icon',
                    z @$chatIcon,
                      icon: 'chat'
                      isTouchTarget: false
                      color: colors.$primary500
                  @model.l.get 'claimClanDialog.text3'
        cancelButton:
          text: @model.l.get 'general.cancel'
          onclick: @cancel
        submitButton:
          text: if isLoading then 'loading...' \
                else if step is 'createGroup'
                then @model.l.get 'claimClanDialog.submitButton'
                else 'claim'
          onclick: if step is 'createGroup' then @createGroup else @claim
