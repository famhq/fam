z = require 'zorium'

FormatService = require '../../services/format'
colors = require '../../colors'

if window?
  require './index.styl'

Icon = require '../icon'

module.exports = class MenuFireAmount
  constructor: ({@model, @router}) ->
    @$fireIcon = new Icon()

    @state = z.state
      me: @model.user.getMe()

  render: =>
    {me} = @state.getValue()

    z '.z-menu-fire-amount',
      FormatService.number me?.fire
      z '.icon',
        z @$fireIcon,
          icon: 'fire'
          color: colors.$quaternary500
          isTouchTarget: false
          size: '20px'
