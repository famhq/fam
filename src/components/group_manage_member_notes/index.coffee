z = require 'zorium'

colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class PlayersTop
  constructor: ({@model, user}) ->
    @state = z.state
      user: user

  render: =>
    {user} = @state.getValue()

    z '.z-players-top',
      'Coming soon!'
