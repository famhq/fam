z = require 'zorium'
_map = require 'lodash/map'
_range = require 'lodash/range'
_pick = require 'lodash/pick'

DeckCards = require '../deck_cards'
DeckPicker = require '../deck_picker'
AppBar = require '../app_bar'
ButtonBack = require '../button_back'
colors = require '../../colors'

if window?
  require './index.styl'

CARDS_PER_DECK = 8

module.exports = class DeckInput
  constructor: ({model, router, selectedCards, selectedCardsStreams}) ->

    if selectedCardsStreams
      selectedCards = selectedCardsStreams.switch()

    selectedDeck = selectedCards.map (cards) ->
      {cards: _map _range(CARDS_PER_DECK), (i) -> cards[i]}

    @$deckCards = new DeckCards {deck: selectedDeck}
    @$deckPicker = new DeckPicker {model, selectedCards, selectedCardsStreams}
    @$appBar = new AppBar {@model}
    @$buttonBack = new ButtonBack {router}

    @state = z.state
      selectedCards: selectedCards
      isDeckPickerVisible: false

  getValue: =>
    {selectedCards} = @state.getValue()
    _map selectedCards, (card) -> _pick card, ['id', 'key']

  render: =>
    {isDeckPickerVisible} = @state.getValue()


    z '.z-deck-input',
      z '.cards', {
        onclick: =>
          @state.set isDeckPickerVisible: true
      },
        z @$deckCards
      if isDeckPickerVisible
        z '.overlay',
          z @$appBar, {
            title: 'Choose cards'
            $topLeftButton: z @$buttonBack, {
              color: colors.$tertiary900
              onclick: (e) =>
                e?.stopPropagation()
                @state.set isDeckPickerVisible: false
            }
          }
          z '.g-grid',
            z @$deckPicker
