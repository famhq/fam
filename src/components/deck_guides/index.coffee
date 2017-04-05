z = require 'zorium'

Icon = require '../../components/icon'

if window?
  require './index.styl'

module.exports = class DeckGuides
  constructor: ({@model, @router, deck}) ->
    me = @model.user.getMe()

    @state = z.state
      me: me
      deck: deck

  render: =>
    {me, deck} = @state.getValue()

    z '.z-deck-guides',
      'guides'
