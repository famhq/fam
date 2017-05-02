z = require 'zorium'
Rx = require 'rx-lite'
_map = require 'lodash/map'

Dialog = require '../dialog'
PrimaryInput = require '../primary_input'
FlatButton = require '../flat_button'
Card = require '../card'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class DeckDialog
  constructor: ({@model, @overlay$, deck}) ->
    @$dialog = new Dialog()

    @$deckCards = new DeckCards {@model, deck}

    @state = z.state
      deck: deck

  render: =>
    {deck} = @state.getValue()

    z '.z-deck-dialog',
      z @$dialog,
        isVanilla: true
        onLeave: =>
          @overlay$.onNext null
        $content:
          z '.z-deck-dialog_dialog',
            z '.title', deck?.title
            z '.deck',
              z @$deckCards, {cardWidth: 65}
        cancelButton:
          text: @model.l.get 'general.cancel'
          onclick: =>
            @overlay$.onNext null
