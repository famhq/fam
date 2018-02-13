z = require 'zorium'
_take = require 'lodash/take'
Environment = require 'clay-environment'
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject

PrimaryInput = require '../primary_input'
PrimaryButton = require '../primary_button'
Dialog = require '../dialog'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class ProfileLanding
  constructor: ({@model, @router}) ->
    me = @model.user.getMe()

    @playerTagValue = new RxBehaviorSubject ''
    @playerTagError = new RxBehaviorSubject null
    @$playerTagInput = new PrimaryInput {
      value: @playerTagValue
      error: @playerTagError
    }
    @$trackButton = new PrimaryButton()
    @$dialog = new Dialog()

    @state = z.state
      me: me
      isLoading: false
      isInfoDialogVisible: false

  onTrack: (e) =>
    e?.preventDefault()
    playerTag = @playerTagValue.getValue()

    {me} = @state.getValue()

    @state.set isLoading: true

    @model.clashRoyaleAPI.setByPlayerId playerTag
    .then =>
      @model.player.getByUserIdAndGameKey me?.id, config.CLASH_ROYAL_ID
      .take(1).toPromise()
    .then =>
      @state.set isLoading: false
    .catch (err) =>
      console.log err?.info
      @playerTagError.next(
        err?.info or @model.l.get 'playersSearch.playerTagError'
      )
      @state.set isLoading: false

  render: =>
    {me, isLoading, isInfoDialogVisible} = @state.getValue()

    z 'form.z-get-player-tag-form', {
      onsubmit: @onTrack
    },
      z '.input',
        z @$playerTagInput,
          hintText: @model.l.get 'playersSearch.playerTagInputHintText'
          onInfo: =>
            @state.set isInfoDialogVisible: true
      z '.button',
        z @$trackButton,
          text: if isLoading \
                then @model.l.get 'general.loading'
                else @model.l.get 'profileLanding.trackButtonText'
          type: 'submit'

      if isLoading
        z @$dialog,
          isVanilla: true
          $content:
            z '.z-get-player-tag-form_dialog',
              z '.description', @model.l.get 'profileLanding.dialogDescription'
              z '.elixir-collector'
          cancelButton:
            text: @model.l.get 'general.cancel'
            isFullWidth: true
            onclick: =>
              @state.set isLoading: false
          onLeave: =>
            @state.set isLoading: false
      else if isInfoDialogVisible
        z @$dialog,
          isVanilla: true
          $content:
            z '.z-get-player-tag-form_dialog',
              @model.l.get 'profileLanding.terms'
          cancelButton:
            text: @model.l.get 'general.done'
            isFullWidth: true
            onclick: =>
              @state.set isInfoDialogVisible: false
          onLeave: =>
            @state.set isInfoDialogVisible: false
          # submitButton:
          #   text: 'Open game profile'
          #   onclick: =>
          #     @model.portal.call 'browser.openWindow', {
          #       url: 'clashroyale://playerProfile'
          #       target: '_system'
          #     }
