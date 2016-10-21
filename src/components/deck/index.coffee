_ = require 'lodash'
z = require 'zorium'
log = require 'loga'
Rx = require 'rx-lite'

colors = require '../../colors'
config = require '../../config'
DeckCards = require '../../components/deck_cards'
Icon = require '../../components/icon'
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

    @$deckCards = new DeckCards {@model, @router, deck}

    @state = z.state
      me: me
      deck: deck

  render: =>
    {me, deck} = @state.getValue()

    totalMatches = (deck?.wins + deck?.losses) or 1

    z '.z-deck',
      z '.deck',
        z '.g-grid',
          z @$deckCards,
            onCardClick: (card) =>
              @router.go "/cards/#{card.id}"
      z '.stats',
        z '.g-grid',
          z '.row',
            z '.icon',
              z @$elixirIcon,
                icon: 'drop'
                color: colors.$tertiary300
                isTouchTarget: false
            z '.stat.bold', 'Average elixir cost'
            z '.right',
              "#{deck?.averageElixirCost}"

          z '.row',
            z '.icon',
              z @$crownIcon,
                icon: 'crown'
                color: colors.$tertiary300
                isTouchTarget: false
            z '.stat.bold', 'Win percentage'
            # z '.right',
            #   'Add stats' # FIXME

          z '.row',
            z '.icon'
            z '.stat', 'Personal average'
            z '.right',
              '??' # FIXME

          z '.row',
            z '.icon'
            z '.stat', 'Community average'
            z '.right',
              FormatService.percentage deck?.wins / totalMatches

          z '.row',
            z '.icon',
              z @$statsIcon,
                icon: 'stats'
                color: colors.$tertiary300
                isTouchTarget: false
            z '.stat.bold', 'Popularity'
            z '.right',
              FormatService.rank deck?.popularity

          z '.row',
            z '.icon',
              z @$notesIcon,
                icon: 'notes'
                color: colors.$tertiary300
                isTouchTarget: false
            z '.stat.bold', 'Personal notes'
            z '.right.button',
              'Edit note'
