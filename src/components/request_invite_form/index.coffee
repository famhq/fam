z = require 'zorium'
log = require 'loga'
Rx = require 'rx-lite'

Icon = require '../icon'
PrimaryButton = require '../primary_button'
PrimaryInput = require '../primary_input'
Form = require '../form'
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class RequestInviteForm
  constructor: ({@model, @router}) ->
    me = @model.user.getMe()

    @clanTagValue = new Rx.BehaviorSubject ''
    @usernameValue = new Rx.BehaviorSubject ''
    @emailValue = new Rx.BehaviorSubject ''
    @$clanTagInput = new PrimaryInput
      value: @clanTagValue
    @$usernameInput = new PrimaryInput
      value: @usernameValue
    @$emailInput = new PrimaryInput
      value: @emailValue
    @$requestButton = new PrimaryButton()

    @$form = new Form()

    @state = z.state
      me: me
      isLoading: false
      isSubmitted: false

  requestInvite: (e) =>
    e?.preventDefault()

    @state.set isLoading: true
    @model.user.requestInvite {
      clanTag: @clanTagValue.getValue()
      username: @usernameValue.getValue()
      email: @emailValue.getValue()
      referrerId: referrer?.id or localStorage?['referrerId']
    }
    .then =>
      @state.set isLoading: false, isSubmitted: true
    .catch =>
      @state.set isLoading: false

  render: ({referrer} = {}) =>
    {me, isLoading, isSubmitted} = @state.getValue()

    z '.z-request-invite-form',
        if isSubmitted
          [
            z '.requested',
              z '.title', 'Invite Requested!'
              z '.description', 'We\'ll get back to you as soon as possible!'
          ]
        else
          z @$form,
            $inputs: [
              z @$clanTagInput,
                hintText: 'Clash Royale clan tag'
              z @$usernameInput,
                hintText: 'Clash Royale username'
              z @$emailInput,
                hintText: 'Email address'
            ]
            $buttons: [
              z @$requestButton,
                text: if isLoading then 'Loading...' else 'Submit request'
                type: 'submit'
                onclick: @requestInvite
                onsubmit: @requestInvite
            ]
