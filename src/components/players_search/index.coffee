z = require 'zorium'
Rx = require 'rx-lite'

PrimaryInput = require '../primary_input'
PrimaryButton = require '../primary_button'
Dialog = require '../dialog'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class PlayersSearch
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

  onSearch: (e) =>
    e?.preventDefault()
    playerTag = @playerTagValue.getValue()

    {me} = @state.getValue()

    @state.set isLoading: true

    @model.signInDialog.openIfGuest me
    .then =>
      @model.userGameData.search playerTag
    .then (userGameData) =>
      console.log 'ug', userGameData
      @router.go "/user/id/#{userGameData?.userIds?[0]}"
    .then =>
      @state.set isLoading: false
    .catch (err) =>
      console.log err
      @playerTagError.onNext 'Hmmm, we can\'t find that tag!'
      @state.set isLoading: false

  render: =>
    {me, isLoading} = @state.getValue()

    z '.z-players-search',
      z '.g-grid',
        z '.image'
        z '.description',
          'Find any player\'s stats, then follow them to stay up to date'
        z 'form.form',
          onsubmit: @onSearch
          z '.input',
            z @$playerTagInput,
              hintText: 'Player ID tag #'
              isCentered: true
          z '.button',
            z @$trackButton,
              text: if isLoading then 'Loading...' else 'Find player'
              type: 'submit'
      if isLoading
        z @$dialog,
          isVanilla: true
          $content:
            z '.z-players-search_dialog',
              z '.description', 'Searching...'
              z '.elixir-collector'
          cancelButton:
            text: 'Cancel'
            isFullWidth: true
            onclick: =>
              @state.set isLoading: false
          onLeave: =>
            @state.set isLoading: false
