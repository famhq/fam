z = require 'zorium'
Rx = require 'rxjs'

Dialog = require '../dialog'
PrimaryInput = require '../primary_input'
FlatButton = require '../flat_button'
Icon = require '../icon'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class ClaimClanDialog
  constructor: ({@model, @router, clan, @overlay$}) ->
    @clanPasswordValue = new Rx.BehaviorSubject ''
    @clanPasswordError = new Rx.BehaviorSubject null
    @$clanPasswordInput = new PrimaryInput
      value: @clanPasswordValue
      error: @clanPasswordError

    @$dialog = new Dialog()
    @$chatIcon = new Icon()
    @$verifiedIcon = new Icon()

    me = @model.user.getMe()
    clanAndMe = Rx.Observable.combineLatest(clan, me, (vals...) -> vals)
    @step = new Rx.ReplaySubject 1
    @step.next clanAndMe.map ([clan, me]) ->
      isClaimedByMe = clan and me and clan.creatorId is me.id
      if isClaimedByMe then 'setPassword'
      else if clan and me then 'claim'
      else 'loading'

    @state = z.state
      step: @step.switch()
      isLoading: false
      clan: clan
      error: null

  afterMount: ->
    ga? 'send', 'event', 'verify', 'claim_clan', 'mount'

  cancel: =>
    @overlay$.next null

  claim: (e) =>
    e?.preventDefault()
    {clan, isLoading} = @state.getValue()

    if isLoading
      return

    @state.set isLoading: true
    @model.clan.claimById clan?.id
    .then =>
      ga? 'send', 'event', 'verify', 'claim_clan', 'verified'
      @step.next Rx.Observable.of 'setPassword'
      @state.set isLoading: false, error: null
    .catch (err) =>
      @state.set error: 'Unable to verify', isLoading: false

  setPassword: (e) =>
    e?.preventDefault()
    {clan, isLoading} = @state.getValue()

    if isLoading
      return

    clanPassword = @clanPasswordValue.getValue()

    @state.set isLoading: true
    @model.clan.updateById clan?.id, {clanPassword}
    .then =>
      ga? 'send', 'event', 'verify', 'claim_clan', 'password_set'
      @state.set isLoading: false, error: null
      @overlay$.next null
    .catch (err) =>
      @state.set error: 'Unable to use that as a password', isLoading: false

  render: =>
    {step, isLoading, clan, error} = @state.getValue()

    z '.z-claim-clan-dialog',
      z @$dialog,
        onLeave: =>
          @overlay$.next null
        isVanilla: true
        $title: if step is 'setPassword' \
                then @model.l.get 'claimClanDialog.setPassword'
                else if step is 'claim'
                then @model.l.get 'claimClanDialog.title'
        $content:
          z '.z-claim-clan-dialog_dialog',
            if step is 'setPassword'
              z 'form.content', {
                onsubmit: @setPassword
              },
                if error
                  z '.error', error
                z '.description',
                  @model.l.get 'claimClanDialog.setPasswordDescription'
                z '.input',
                  z @$clanPasswordInput, {
                    type: 'text'
                    hintText: @model.l.get 'general.password'
                  }
            else if step is 'claim'
              z '.content',
                if error
                  z '.error', error
                z '.text',
                  @model.l.get 'claimClanDialog.text1'
                z '.code', clan?.code
                z '.text', @model.l.get 'claimClanDialog.text2'
                z '.unlock',
                  z '.icon',
                    z @$chatIcon,
                      icon: 'chat'
                      isTouchTarget: false
                      color: colors.$primary500
                  @model.l.get 'claimClanDialog.text3'
                z '.unlock',
                  z '.icon',
                    z @$verifiedIcon,
                      icon: 'verified'
                      isTouchTarget: false
                      color: colors.$primary500
                  @model.l.get 'claimClanDialog.text4'
        cancelButton:
          text: @model.l.get 'general.cancel'
          onclick: @cancel
        submitButton:
          text: if isLoading or step is 'loading' then 'loading...' \
                else if step is 'setPassword'
                then @model.l.get 'claimClanDialog.setPassword'
                else if step is 'claim'
                then @model.l.get 'claimClanDialog.submitButton'
          onclick: if step is 'setPassword' \
                   then @setPassword
                   else if step is 'claim'
                   then @claim
