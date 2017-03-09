z = require 'zorium'
Rx = require 'rx-lite'

PrimaryInput = require '../primary_input'
PrimaryButton = require '../primary_button'
Dialog = require '../dialog'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class ProfileLanding
  constructor: ({@model, @router}) ->
    me = @model.user.getMe()

    @playerTagValue = new Rx.BehaviorSubject ''
    @playerTagError = new Rx.BehaviorSubject null
    @$playerTagInput = new PrimaryInput {
      value: @playerTagValue
      error: @playerTagError
    }
    @$trackButton = new PrimaryButton()
    @$dialog = new Dialog()

    @state = z.state
      me: me
      isLoading: false

  onTrack: (e) =>
    e?.preventDefault()
    playerTag = @playerTagValue.getValue()

    @state.set isLoading: true

    @model.userGameData.updateMeByGameId null, {
      playerId: playerTag
    }
    .then =>
      @model.clashRoyaleAPI.refreshByPlayerTag playerTag
      .then =>
        @model.userGameData.getMeByGameId config.CLASH_ROYAL_ID
        .take(1).toPromise()
      .then =>
        @state.set isLoading: false
    .catch (err) =>
      console.log err
      @playerTagError.onNext 'Hmmm, we can\'t find that tag!'
      @state.set isLoading: false

  render: =>
    {me, isLoading} = @state.getValue()

    z '.z-profile-landing',
      z '.g-grid',
        z '.image'
        z '.description',
          'Enter your player ID tag to start automatically tracking your wins,
          losses, donations, and more'
        z 'form.form',
          onsubmit: @onTrack
          z '.input',
            z @$playerTagInput,
              hintText: 'Player ID tag #'
              isCentered: true
          z '.button',
            z @$trackButton,
              text: if isLoading then 'Loading...' else 'Track my stats'
              type: 'submit'
      if isLoading
        z @$dialog,
          isVanilla: true
          $content:
            z '.z-profile-landing_dialog',
              z '.description', 'Collecting your stats...'
              z '.elixir-collector'
          cancelButton:
            text: 'Cancel'
            isFullWidth: true
            onclick: =>
              @state.set isLoading: false
          onLeave: =>
            @state.set isLoading: false
