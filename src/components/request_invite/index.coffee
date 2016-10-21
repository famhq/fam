_ = require 'lodash'
z = require 'zorium'
log = require 'loga'
Rx = require 'rx-lite'

Icon = require '../icon'
PrimaryButton = require '../primary_button'
PrimaryInput = require '../primary_input'
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class RequestInvite
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

    @state = z.state
      me: me
      isLoading: false
      isSubmitted: false

  render: =>
    {me, isLoading, isSubmitted} = @state.getValue()

    z '.z-request-invite',
      if isSubmitted
        [
          z '.title', 'Invite Requested!'
          z '.description', 'We\'ll get back to you as soon as possible!'
        ]
      else
        [
          z '.title', 'Request an invite'
          z '.description',
            z 'p', 'Only the most elite players are permitted to join'
            z 'p', 'Your request is subject to review and approval'
          z '.input',
            z @$clanTagInput,
              hintText: 'Clash Royale clan tag'
          z '.input',
            z @$usernameInput,
              hintText: 'Clash Royale username'
          z '.input',
            z @$emailInput,
              hintText: 'Email address'
          z '.button',
            z @$requestButton,
              text: if isLoading then 'Loading...' else 'Submit request'
              onclick: =>
                @state.set isLoading: true
                @model.user.requestInvite {
                  clanTag: @clanTagValue.getValue()
                  username: @usernameValue.getValue()
                  email: @emailValue.getValue()
                }
                .then =>
                  @state.set isLoading: false, isSubmitted: true
                .catch =>
                  @state.set isLoading: false
        ]
