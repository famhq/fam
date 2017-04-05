z = require 'zorium'
Rx = require 'rx-lite'
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
          @overlay$.onNext null
        $content:
          z '.z-card-picker-dialog_dialog',
            z '.title', 'Insert card'
            z '.cards',
              _map cards, ({card, $card}) =>
                z '.card', {
                  onclick: =>
                    @onPickFn? card
                    @overlay$.onNext null
                },
                  z '.image', z $card, {width: 50}
        cancelButton:
          text: 'cancel'
          onclick: =>
            @overlay$.onNext null
