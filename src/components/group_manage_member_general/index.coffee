z = require 'zorium'

colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class GroupManageMemberGeneral
  constructor: ({@model, group, user}) ->
    @state = z.state
      group: group
      user: user

  render: =>
    {group, user} = @state.getValue()

    z '.z-group-manage-member-general',
      'General...'
