z = require 'zorium'
Rx = require 'rxjs'
Environment = require 'clay-environment'

AdsenseAd = require '../adsense_ad'
PrimaryInput = require '../primary_input'
PrimaryButton = require '../primary_button'
Dialog = require '../dialog'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class PlayersSearch
  constructor: ({@model, @router, gameKey}) ->
    me = @model.user.getMe()

    @playerTagValue = new Rx.BehaviorSubject ''
    @playerTagError = new Rx.BehaviorSubject null
    @$playerTagInput = new PrimaryInput {
      value: @playerTagValue
      error: @playerTagError
    }
    @$trackButton = new PrimaryButton()
    @$dialog = new Dialog()
    @$adsenseAd = new AdsenseAd()

    @state = z.state
      me: me
      gameKey: gameKey
      isLoading: false

  onSearch: (e) =>
    e?.preventDefault()
    playerTag = @playerTagValue.getValue()

    {me, gameKey} = @state.getValue()

    @state.set isLoading: true

    @model.signInDialog.openIfGuest me
    .then =>
      @model.player.search playerTag
    .then (player) =>
      userId = player?.userId
      @router.go 'userById', {gameKey, id: userId}
    .then =>
      @state.set isLoading: false
    .catch (err) =>
      console.log err
      @playerTagError.next @model.l.get 'playersSearch.playerTagError'
      @state.set isLoading: false

  render: =>
    {me, isLoading} = @state.getValue()

    z '.z-players-search',
      z '.g-grid',
        z '.image'
        z '.description',
          @model.l.get 'playersSearch.description'
        z 'form.form',
          onsubmit: @onSearch
          z '.input',
            z @$playerTagInput,
              hintText: @model.l.get 'playersSearch.playerTagInputHintText'
              isCentered: true
          z '.button',
            z @$trackButton,
              text: if isLoading \
                    then @model.l.get 'general.loading'
                    else @model.l.get 'playersSearch.trackButtonText'
              type: 'submit'


        if Environment.isMobile() and not Environment.isGameApp(config.GAME_KEY)
          z '.ad',
            z @$adsenseAd, {
              slot: 'mobile300x250'
            }
        else if not Environment.isMobile()
          z '.ad',
            z @$adsenseAd, {
              slot: 'desktop728x90'
            }

      if isLoading
        z @$dialog,
          isVanilla: true
          $content:
            z '.z-players-search_dialog',
              z '.description', @model.l.get 'playersSearch.dialogDescription'
              z '.elixir-collector'
          cancelButton:
            text: @model.l.get 'general.cancel'
            isFullWidth: true
            onclick: =>
              @state.set isLoading: false
          onLeave: =>
            @state.set isLoading: false
