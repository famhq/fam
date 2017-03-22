z = require 'zorium'
Rx = require 'rx-lite'
_map = require 'lodash/map'
_isEmpty = require 'lodash/isEmpty'

colors = require '../../colors'
DeckCards = require '../deck_cards'
Base = require '../base'
Icon = require '../icon'
Spinner = require '../spinner'

if window?
  require './index.styl'

CARDS_PER_ROW = 4
PADDING = 16

module.exports = class DeckList extends Base
  constructor: ({@model, @router, sort, filter}) ->
    @$spinner = new Spinner()

    me = @model.user.getMe()
    favoritedDeckIds = @model.clashRoyaleUserDeck.getFavoritedDeckIds()
    decksAndFavoritedDeckIds = Rx.Observable.combineLatest(
      @model.clashRoyaleDeck.getAll({sort, filter})
      favoritedDeckIds
      (vals...) -> vals
    )

    @state = z.state
      me: @model.user.getMe()
      filter: filter
      windowSize: @model.window.getSize()
      decks: decksAndFavoritedDeckIds.map ([decks, favoritedDeckIds]) =>
        _map decks, (deck) =>
          hasDeck =  favoritedDeckIds and
            favoritedDeckIds.indexOf(deck.id) isnt -1

          $el = @getCached$ "#{filter}-#{deck.id}", DeckCards, {
            @model, @router, deck
          }
          {
            deck
            hasDeck
            $deck: $el
            $starIcon: new Icon()
            $chevronIcon: new Icon()
          }

  afterMount: (@$$el) => null

  render: =>
    {me, decks, filter, windowSize} = @state.getValue()

    cardWidth = (@$$el?.children?[0]?.offsetWidth - (PADDING * 2)) /
                  CARDS_PER_ROW

    z '.z-deck-list',
      z '.decks', {
        # force scrollbar initially
        style:
          minHeight: "#{windowSize.height * 1.2}px"
      },
        if decks and _isEmpty decks
          z '.no-decks',
            'No decks found. '
            if filter is 'mine'
              'Select a popular deck to add it, or create a new deck.'
        else if decks
          _map decks, ({deck, hasDeck, $deck, $starIcon, $chevronIcon}) =>
            [
              @router.link z 'a.deck', {
                href: "/deck/#{deck.id}"
              },
                z '.g-grid',
                  z '.info',
                    z '.star',
                      z $starIcon,
                        icon: if hasDeck then 'star' else 'star-outline'
                        isAlignedLeft: true
                        color: if hasDeck \
                               then colors.$primary500
                               else colors.$white12
                        onclick: (e) =>
                          e?.stopPropagation()
                          e?.preventDefault()
                          if hasDeck
                            @model.clashRoyaleUserDeck.unfavorite {
                              deckId: deck.id
                            }
                          else
                            @model.clashRoyaleUserDeck.favorite {
                              deckId: deck.id
                            }
                    z '.name', deck.name or 'Nameless'
                    z '.chevron',
                      z $chevronIcon,
                        icon: 'chevron-right'
                        color: colors.$primary500
                        isTouchTarget: false
                  z '.cards',
                    $deck
              z '.divider'
            ]
        else
          @$spinner
