z = require 'zorium'
Rx = require 'rx-lite'
_take = require 'lodash/take'
Environment = require 'clay-environment'

PrimaryInput = require '../primary_input'
PrimaryButton = require '../primary_button'
SecondaryButton = require '../secondary_button'
Dialog = require '../dialog'
PlayerList = require '../player_list'
DecksGuides = require '../decks_guides'
config = require '../../config'

TOP_PLAYER_COUNT = 20

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
    @$findPlayerButton = new SecondaryButton()
    @$loginButton = new SecondaryButton()
    @$dialog = new Dialog()

    @$playerList = new PlayerList {
      @model
      @selectedProfileDialogUser
      players: @model.player.getTop().map (players) ->
        _take players, TOP_PLAYER_COUNT
    }


    @$decksGuides = new DecksGuides {@model, @router, sort: 'popular'}

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
    {me, isLoading, isInfoDialogVisible} = @state.getValue()

    z '.z-profile-landing',
      z '.header-background'
      z '.content',
        z '.g-grid',
          z '.header',
            z '.title',
              @model.l.get 'profileLanding.title'
            z '.description',
              @model.l.get 'profileLanding.description'
          z 'form.form',
            onsubmit: @onTrack
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

      z '.g-grid',
        z '.actions',
          z '.button',
            z @$findPlayerButton,
              text: @model.l.get 'playersSearch.trackButtonText'
              isFullWidth: true
              onclick: =>
                @router.go '/players/search'
          z '.button',
            z @$loginButton,
              text: @model.l.get 'general.signIn'
              isFullWidth: true
              onclick: =>
                @model.signInDialog.open 'signIn'

        z '.subhead', @model.l.get 'playersPage.playersTop'
        z @$playerList, {
          onclick: ({player}) =>
            userId = player?.userId
            @router.go "/user/id/#{userId}"
        }

        z '.terms',
          z 'p',
            @model.l.get 'profileLanding.terms2'
            z 'a', {
              href: '/policies'
            }, ' TOS'

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
      else if isInfoDialogVisible
        z @$dialog,
          isVanilla: true
          $content:
            z '.z-profile-landing_dialog',
              @model.l.get 'profileLanding.terms'
          cancelButton:
            text: @model.l.get 'general.done'
            isFullWidth: true
            onclick: =>
              @state.set isInfoDialogVisible: false
          onLeave: =>
            @state.set isInfoDialogVisible: false
