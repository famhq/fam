_ = require 'lodash'
z = require 'zorium'
log = require 'loga'
Rx = require 'rx-lite'

colors = require '../../colors'
config = require '../../config'
DeckCards = require '../../components/deck_cards'
DeckStats = require '../../components/deck_stats'
Icon = require '../../components/icon'
Tabs = require '../../components/tabs'
PrimaryButton = require '../../components/primary_button'
FormatService = require '../../services/format'

if window?
  require './index.styl'

module.exports = class Deck
  constructor: ({@model, @router, deck}) ->
    me = @model.user.getMe()

    @$elixirIcon = new Icon()
    @$crownIcon = new Icon()
    @$statsIcon = new Icon()
    @$notesIcon = new Icon()
    @$setAsDeckButton = new PrimaryButton()
    @$deckStats = new DeckStats {@model, @router, deck}
    @$tabs = new Tabs {@model}

    @$deckCards = new DeckCards {@model, @router, deck}

    @state = z.state
      me: me
      deck: deck
      isSetDeckLoading: false

  render: =>
    {me, deck, isSetDeckLoading} = @state.getValue()

    totalMatches = (deck?.wins + deck?.losses) or 1

    z '.z-deck',
      z '.deck',
        z '.g-grid',
          z @$deckCards,
            onCardClick: (card) =>
              @router.go "/cards/#{card.id}"
          z '.set-as-deck',
            z @$setAsDeckButton,
              text: if isSetDeckLoading \
                    then 'Loading...'
                    else 'Set as current deck'
              onclick: =>
                @state.set isSetDeckLoading: true
                @model.userData.setClashRoyaleDeckId deck.id
                .then =>
                  @state.set isSetDeckLoading: false
      z @$tabs,
        isBarFixed: false
        tabs: [
          {
            $menuText: 'Stats'
            $el: @$deckStats
          }
          {
            $menuText: 'Notes'
            $el: null
          }
        ]
