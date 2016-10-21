_ = require 'lodash'
z = require 'zorium'
log = require 'loga'
Rx = require 'rx-lite'

colors = require '../../colors'
config = require '../../config'
PrimaryInput = require '../primary_input'
Icon = require '../icon'
DeckCards = require '../deck_cards'

if window?
  require './index.styl'

CARDS_PER_DECK = 8

module.exports = class NewThread
  constructor: ({@model, @router}) ->
    @nameValue ?= new Rx.BehaviorSubject ''
    @nameError ?= new Rx.BehaviorSubject null
    @$nameInput = new PrimaryInput
      value: @nameValue
      error: @nameError

    @selectedCards = new Rx.BehaviorSubject []
    selectedDeck = @selectedCards.map (cards) ->
      {cards: _.map _.range(CARDS_PER_DECK), (i) -> cards[i]}

    allCards = @model.clashRoyaleCard.getAll()
    allCardsAndSelectedCards = Rx.Observable.combineLatest(
      allCards
      @selectedCards
      (vals...) -> vals
    )
    allDeck = allCardsAndSelectedCards.map ([allCards, selectedCards]) ->
      cards = _.filter allCards, (card) ->
        not _.find selectedCards, {id: card.id}
      {cards}
    @$selectedCards = new DeckCards {@model, @router, deck: selectedDeck}
    @$allCards = new DeckCards {@model, @router, deck: allDeck}

    @$cancelIcon = new Icon()
    @$saveIcon = new Icon()

    @state = z.state
      me: @model.user.getMe()
      selectedCards: @selectedCards
      isLoading: false

  create: =>
    {selectedCards, isLoading} = @state.getValue()
    if selectedCards.length is CARDS_PER_DECK and not isLoading
      @state.set isLoading: true
      @model.clashRoyaleDeck.create {
        cardIds: _.map selectedCards, 'id'
        cardKeys: _.map selectedCards, 'key'
        name: @nameValue.getValue()
      }
      .then =>
        @state.set isLoading: false

  render: =>
    {me, selectedCards, isLoading} = @state.getValue()

    z '.z-new-deck',
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
      z '.selected',
        z @$selectedCards,
          onCardClick: (card) =>
            @selectedCards.onNext _.filter selectedCards, (selectedCard) ->
              card.id isnt selectedCard.id
      z '.cards',
        z '.scroller',
          z @$allCards, {
            onCardClick: (card) =>
              if selectedCards.length < CARDS_PER_DECK
                @selectedCards.onNext selectedCards.concat [card]
          }
