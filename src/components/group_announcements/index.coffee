z = require 'zorium'

if window?
  require './index.styl'

module.exports = class GroupAnnouncements
  constructor: ({@model, @router, group}) ->
    @state = z.state {}

  render: =>
    {group} = @state.getValue()

    z '.z-group-announcements',
      z '.g-grid',
        'Announcements coming soon...'
