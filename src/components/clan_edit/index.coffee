z = require 'zorium'
Rx = require 'rx-lite'

ActionBar = require '../action_bar'
PrimaryInput = require '../primary_input'
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class ClanEdit
  hasBottomBanner: true

  constructor: ({@model, @router, clan}) ->
    me = @model.user.getMe()

    @passwordValueStreams = new Rx.ReplaySubject 1
    @passwordValueStreams.onNext clan.map (clan) ->
      clan.password
    @passwordError = new Rx.BehaviorSubject null

    @$actionBar = new ActionBar {@model, @router}
    @$passwordInput = new PrimaryInput
      valueStreams: @passwordValueStreams
      error: @passwordError

    @state = z.state
      password: @passwordValueStreams.switch()
      clan: clan
      isSaving: false

  save: =>
    {clan, password, isSaving} = @state.getValue()
    if isSaving
      return

    @state.set isSaving: true
    @passwordError.onNext null

    @model.clan.updateById clan.id, {clanPassword: password}
    .then =>
      @state.set isSaving: false
      @router.go '/clan'

  render: =>
    {me, isSaving} = @state.getValue()

    z '.z-clan-edit',
      z @$actionBar, {
        isSaving
        title: 'Clan settings'
        cancel:
          onclick: =>
            @router.back()
        save:
          onclick: @save
      }
      z '.g-grid',
        z '.section',
          z '.input',
            z @$passwordInput,
              hintText: @model.l.get 'clanEdit.clanPassword'
