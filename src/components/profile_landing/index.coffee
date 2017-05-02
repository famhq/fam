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
      @playerTagError.onNext(
        err?.info or @model.l.get 'playersSearch.playerTagError'
      )
      @state.set isLoading: false

  render: =>
    {me, isLoading} = @state.getValue()

    z '.z-profile-landing',
      z '.g-grid',
        z '.image'
        z '.description',
          @model.l.get 'profileLanding.description'
        z 'form.form',
          onsubmit: @onTrack
          z '.input',
            z @$playerTagInput,
              hintText: @model.l.get 'playersSearch.playerTagInputHintText'
              isCentered: true
          z '.button',
            z @$trackButton,
              text: if isLoading \
                    then @model.l.get 'general.loading'
                    else @model.l.get 'profileLanding.trackButtonText'
              type: 'submit'
        z '.terms',
          z 'p',
            @model.l.get 'profileLanding.terms'
          z 'p',
            @model.l.get 'profileLanding.terms2'
      if isLoading
        z @$dialog,
          isVanilla: true
          $content:
            z '.z-profile-landing_dialog',
              z '.description', @model.l.get 'profileLanding.dialogDescription'
              z '.elixir-collector'
          cancelButton:
            text: @model.l.get 'general.cancel'
            isFullWidth: true
            onclick: =>
              @state.set isLoading: false
          onLeave: =>
            @state.set isLoading: false
