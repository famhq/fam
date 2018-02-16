z = require 'zorium'
_take = require 'lodash/take'
_map = require 'lodash/map'
Environment = require 'clay-environment'
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject

Icon = require '../icon'
PrimaryInput = require '../primary_input'
PrimaryButton = require '../primary_button'
Dialog = require '../dialog'
config = require '../../config'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class FortniteGetPlayerTagForm
  constructor: ({@model, @router}) ->
    me = @model.user.getMe()

    @networks =
      pc:
        $icon: new Icon()
        iconName: 'pc'
        selectedColor: '#ffffff'
      ps4:
        $icon: new Icon()
        iconName: 'playstation'
        selectedColor: '#0071CF'
      xb1:
        $icon: new Icon()
        iconName: 'xbox'
        selectedColor: '#5dc21e'

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
      network: 'pc'
      isInfoDialogVisible: false

  onTrack: (e) =>
    e?.preventDefault()
    fortniteUsername = @fortniteUsernameValue.getValue()

    {me, network} = @state.getValue()

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
    {me, network, isLoading, isInfoDialogVisible} = @state.getValue()

    z 'form.z-fortnite-get-player-tag-form', {
      onsubmit: @onTrack
    },
      z '.networks',
        _map @networks, ({$icon, iconName, selectedColor}, networkKey) =>
          z $icon,
            icon: iconName
            color: if network is networkKey \
                   then selectedColor
                   else colors.$tertiary300
            onclick: =>
              @state.set network: networkKey

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
