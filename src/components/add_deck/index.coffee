z = require 'zorium'
Rx = require 'rx-lite'
_map = require 'lodash/map'

PrimaryInput = require '../primary_input'
Icon = require '../icon'
DeckPicker = require '../deck_picker'
colors = require '../../colors'

if window?
  require './index.styl'

CARDS_PER_DECK = 8

module.exports = class AddDeck
  constructor: ({@model, @router}) ->
    @nameValue ?= new Rx.BehaviorSubject ''
    @nameError ?= new Rx.BehaviorSubject null
    @$nameInput = new PrimaryInput
      value: @nameValue
      error: @nameError

    selectedCards = new Rx.BehaviorSubject []

    @$deckPicker = new DeckPicker {@model, selectedCards}

    @$cancelIcon = new Icon()
    @$saveIcon = new Icon()

    @state = z.state
      me: @model.user.getMe()
      selectedCards: selectedCards
      isLoading: false

  create: =>
    {selectedCards, isLoading} = @state.getValue()
    if selectedCards.length is CARDS_PER_DECK and not isLoading
      @state.set isLoading: true
      @model.clashRoyaleUserDeck.create {
        cardIds: _map selectedCards, 'id'
        cardKeys: _map selectedCards, 'key'
        name: @nameValue.getValue()
      }
      .then =>
        @state.set isLoading: false
        @router.go '/decks'

  render: =>
    {me, selectedCards, isLoading} = @state.getValue()

    z '.z-add-deck',
      z '.header',
        z '.icon',
          z @$cancelIcon,
            icon: 'close'
            color: colors.$primary500
            onclick: =>
              @router.back()
        z '.name',
          z @$nameInput, {hintText: 'Enter a name...'}
        z '.icon',
          z @$saveIcon,
            icon: if isLoading then 'ellipsis' else 'check'
            color: colors.$primary500
            onclick: @create
      z @$deckPicker
