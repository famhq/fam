_ = require 'lodash'
z = require 'zorium'
log = require 'loga'
Rx = require 'rx-lite'

GroupHeader = require '../group_header'
config = require '../../config'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class GroupInfo
  constructor: ({@model, @router, group}) ->
    @$groupHeader = new GroupHeader {group}
    @state = z.state {group}

  render: =>
    {group} = @state.getValue()

    z '.z-group-info',
      @$groupHeader
      z '.g-grid',
        z 'h2.title', 'About'
        z '.about', group?.description

        z '.stats',
          z @$membersIcon,
            icon: 'friends'
            color: colors.$tertiary500
