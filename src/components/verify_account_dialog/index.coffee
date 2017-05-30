z = require 'zorium'
Rx = require 'rx-lite'

Dialog = require '../dialog'
PrimaryInput = require '../primary_input'
FlatButton = require '../flat_button'
Icon = require '../icon'
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class VerifyAccountDialog
  constructor: ({@model, @router, @overlay$}) ->

    player = @model.user.getMe().flatMapLatest ({id}) =>
      @model.player.getByUserIdAndGameId id, config.CLASH_ROYALE_ID
      .map (player) ->
        return player or {}

    @goldValue = new Rx.BehaviorSubject ''
    @goldError = new Rx.BehaviorSubject null
    @$goldInput = new PrimaryInput
      value: @goldValue
      error: @goldError

    @hiValueStreams = new Rx.ReplaySubject null
    @hiValueStreams.onNext player.map (player) ->
      console.log player
      player?.hi
    @hiError = new Rx.BehaviorSubject null
    @$hiInput = new PrimaryInput
      valueStreams: @hiValueStreams
      error: @hiError

    @loValue = new Rx.BehaviorSubject ''
    @loError = new Rx.BehaviorSubject null
    @$loInput = new PrimaryInput
      value: @loValue
      error: @loError

    @$dialog = new Dialog()

    @state = z.state
      isLoading: false
      error: null

  cancel: =>
    @overlay$.onNext null

  verify: (e) =>
    e?.preventDefault()


    gold = @goldValue.getValue()
    lo = @loValue.getValue()

    @state.set isLoading: true
    @model.player.verifyMe {gold, lo}
    .then =>
      @state.set isLoading: false, error: null
      @overlay$.onNext null
    .catch (err) =>
      @state.set
        error: err?.info
        isLoading: false

  render: =>
    {step, isLoading, error} = @state.getValue()

    z '.z-verify-account-dialog',
      z @$dialog,
        onLeave: =>
          @overlay$.onNext null
        isVanilla: true
        $title: @model.l.get 'clanInfo.verifySelf'
        $content:
          z '.z-verify-account-dialog_dialog',
            z 'form.content', {
              onsubmit: @verify
            },
              z '.error', error
              z '.input',
                z @$goldInput, {
                  type: 'number'
                  hintText: @model.l.get 'verifyAccountDialog.currentGold'
                }
              z '.description',
                @model.l.get 'verifyAccountDialog.profileIdDescription'
              z '.input',
                z '.hi',
                  z @$hiInput, {
                    type: 'number'
                    hintText: 'Pt 1'
                  }
                z '.hyphen', '-'
                z @$loInput, {
                  type: 'number'
                  hintText: 'Pt 2'
                }
        cancelButton:
          text: @model.l.get 'general.cancel'
          onclick: @cancel
        submitButton:
          text: if isLoading then @model.l.get 'general.loading' \
                else @model.l.get 'general.verify'
          onclick: @verify
