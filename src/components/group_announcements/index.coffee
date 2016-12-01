_ = require 'lodash'
z = require 'zorium'
log = require 'loga'
Rx = require 'rx-lite'

config = require '../../config'

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
