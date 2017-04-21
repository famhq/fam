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

    {me} = @state.getValue()

    @state.set isLoading: true

    @model.clashRoyaleAPI.refreshByPlayerTag playerTag
    .then =>
      @model.player.getByUserIdAndGameId me?.id, config.CLASH_ROYAL_ID
      .take(1).toPromise()
    .then =>
      @state.set isLoading: false
    .catch (err) =>
      console.log err?.info
      @playerTagError.onNext  err?.info or 'Hmmm, we can\'t find that tag!'
      @state.set isLoading: false

  render: =>
    {me, isLoading} = @state.getValue()

    z '.z-profile-landing',
      z '.g-grid',
        z '.image'
        z '.description',
          z 'p',
            z 'strong', 'The amazing WithZack posted a video about us, so our servers are getting pounded. Sorry if it\'s slow for you now - check back soon!'
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
        z '.terms',
          z 'p',
            'You can find your player tag by tapping on your username in
            Clash Royale to open your profile. It\'s right below your username
            in the profile.'
          z 'p',
            'This content is not affiliated with, endorsed, sponsored, or
            specifically approved by Supercell and Supercell is
            not responsible for it.'
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
