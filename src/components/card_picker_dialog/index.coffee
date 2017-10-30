z = require 'zorium'
_map = require 'lodash/map'

Dialog = require '../dialog'
Card = require '../card'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class CardPickerDialog
  constructor: ({@model, @overlay$}) ->
    @$dialog = new Dialog()

    @onPickFn = null

    @state = z.state
      cards: @model.clashRoyaleCard.getAll().map (cards) ->
        _map cards, (card) ->
          {
            card
            $card: new Card {card}
          }

  onPick: (@onPickFn) => null

  render: =>
    {cards} = @state.getValue()

    z '.z-card-picker-dialog',
      z @$dialog,
        isVanilla: true
        onLeave: =>
          @overlay$.next null
        $content:
          z '.z-card-picker-dialog_dialog',
            z '.title', @model.l.get 'cardPickerDialog.title'
            z '.cards',
              _map cards, ({card, $card}) =>
                z '.card', {
                  onclick: =>
                    @onPickFn? card
                    @overlay$.next null
                },
                  z '.image', z $card, {width: 50}
        cancelButton:
          text: @model.l.get 'general.cancel'
          onclick: =>
            @overlay$.next null
