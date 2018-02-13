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

module.exports = class FortniteGetPlayerTagForm
  constructor: ({@model, @router}) ->
    me = @model.user.getMe()

    @fortniteUsernameValue = new RxBehaviorSubject ''
    @fortniteUsernameError = new RxBehaviorSubject null
    @$fortniteUsernameInput = new PrimaryInput {
      value: @fortniteUsernameValue
      error: @fortniteUsernameError
    }
    @$trackButton = new PrimaryButton()
    @$dialog = new Dialog()

    @state = z.state
      me: me
      isLoading: false
      isInfoDialogVisible: false

  onTrack: (e) =>
    e?.preventDefault()
    network = 'pc' # FIXME
    fortniteUsername = @fortniteUsernameValue.getValue()

    {me} = @state.getValue()

    @state.set isLoading: true

    @model.fortnitePlayer.setByPlayerId "#{network}:#{fortniteUsername}"
    .then =>
      @model.player.getByUserIdAndGameKey me?.id, config.CLASH_ROYAL_ID
      .take(1).toPromise()
    .then =>
      @state.set isLoading: false
    .catch (err) =>
      console.log err?.info
      @fortniteUsernameError.next(
        err?.info or @model.l.get 'playersSearch.playerTagError'
      )
      @state.set isLoading: false

  render: =>
    {me, isLoading, isInfoDialogVisible} = @state.getValue()

    z 'form.z-fortnite-get-player-tag-form', {
      onsubmit: @onTrack
    },
      z '.input',
        z @$fortniteUsernameInput,
          hintText: @model.l.get 'fortniteGetPlayerTagForm.fortniteName'
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
