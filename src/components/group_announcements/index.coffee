z = require 'zorium'

if window?
  require './index.styl'

module.exports = class GroupAnnouncements
  constructor: ({@model, @router}) ->
    @state = z.state {}

  render: =>
    {} = @state.getValue()

    z '.z-group-announcements',
      z '.g-grid',
        'Announcements coming soon...'
