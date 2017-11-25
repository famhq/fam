z = require 'zorium'
_find = require 'lodash/find'
_map = require 'lodash/map'
RxObservable = require('rxjs/Observable').Observable
require 'rxjs/add/operator/map'
require 'rxjs/add/operator/switchMap'

PrimaryButton = require '../primary_button'
SecondaryButton = require '../secondary_button'
DeckCards = require '../deck_cards'
Dialog = require '../dialog'
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class VerifyAccountDialog
  constructor: ({@model, @router, @overlay$}) ->
    me = @model.user.getMe()
    player = me.switchMap ({id}) =>
      @model.player.getByUserIdAndGameId id, config.CLASH_ROYALE_ID

    verifyDeckId = @model.player.getVerifyDeckId()

    deck = verifyDeckId.map ({deckId, copyIds}) ->
      cards = _map deckId.split('|'), (cardKey) ->
        {key: cardKey}
      {cards}

    @$deckCards = new DeckCards {deck, cardsPerRow: 4}
    @$dialog = new Dialog()
    @$copyDeckButton = new PrimaryButton()

    @state = z.state
      isLoading: false
      copyIds: verifyDeckId.map ({copyIds}) -> copyIds

  verify: =>
    @state.set isLoading: true
    @model.player.verifyMe()
    .then =>
      @state.set isLoading: true
      @overlay$.next null
    .catch (err) =>
      @state.set
        error: @model.l.get 'verifyAccountDialog.error'
        isLoading: false

  render: =>
    {isLoading, copyIds, error} = @state.getValue()

    z '.z-verify-account-dialog',
      z @$dialog,
        onLeave: =>
          @overlay$.next null
        isVanilla: true
        $title: @model.l.get 'general.verify'
        $content:
          z '.z-verify-account-dialog_dialog',
            z '.error', error
            z '.description',
              @model.l.get 'verifyAccountDialog.description'
            z @$deckCards
            z @$copyDeckButton,
              text: @model.l.get 'verifyAccountDialog.copyDeck'
              onclick: =>
                @model.portal.call 'browser.openWindow', {
                  url: "clashroyale://copyDeck?deck=#{copyIds.join(';')}"
                }
        cancelButton:
          text: @model.l.get 'general.cancel'
          onclick: =>
            @overlay$.next null
        submitButton:
          text: if isLoading then 'loading...' \
                else @model.l.get 'general.verify'
          onclick: @verify
