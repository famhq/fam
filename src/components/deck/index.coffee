_ = require 'lodash'
z = require 'zorium'
log = require 'loga'
Rx = require 'rx-lite'

colors = require '../../colors'
config = require '../../config'
DeckCards = require '../../components/deck_cards'
Icon = require '../../components/icon'

if window?
  require './index.styl'

module.exports = class Deck
  constructor: ({@model, @router, deck}) ->
    me = @model.user.getMe()

    @$elixerIcon = new Icon()
    @$crownIcon = new Icon()
    @$statsIcon = new Icon()
    @$notesIcon = new Icon()

    @$deckCards = new DeckCards {@model, @router, deck}

    @state = z.state
      me: me

  render: =>
    {me} = @state.getValue()

    z '.z-deck',
      z '.deck',
        @$deckCards
      z '.stats',
        z '.row',
          z '.icon',
            z @$elixerIcon,
              icon: 'drop'
              color: colors.$tertiary300
              isTouchTarget: false
          z '.stat.bold', 'Average elixer cost'
          z '.right',
            '3.6' # FIXME

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
            '71%' # FIXME

        z '.row',
          z '.icon'
          z '.stat', 'Community average'
          z '.right',
            '68%' # FIXME'

        z '.row',
          z '.icon',
            z @$statsIcon,
              icon: 'stats'
              color: colors.$tertiary300
              isTouchTarget: false
          z '.stat.bold', 'Popularity'
          z '.right',
            '7%' # FIXME

        z '.row',
          z '.icon',
            z @$notesIcon,
              icon: 'notes'
              color: colors.$tertiary300
              isTouchTarget: false
          z '.stat.bold', 'Personal notes'
          z '.right.button',
            'Edit note'
