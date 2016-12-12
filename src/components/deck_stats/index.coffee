z = require 'zorium'

colors = require '../../colors'
Icon = require '../../components/icon'
FormatService = require '../../services/format'

if window?
  require './index.styl'

module.exports = class DeckStats
  constructor: ({@model, @router, deck}) ->
    me = @model.user.getMe()

    @$elixirIcon = new Icon()
    @$crownIcon = new Icon()
    @$statsIcon = new Icon()

    @state = z.state
      me: me
      deck: deck

  render: =>
    {me, deck} = @state.getValue()

    totalMatches = (deck?.wins + deck?.losses) or 1

    z '.z-deck-stats',
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
