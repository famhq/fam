z = require 'zorium'

GroupBadge = require '../group_badge'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class GroupHeader
  constructor: ({@model, @router, group}) ->
    @$groupBadge = new GroupBadge {group}
    @state = z.state {group}

  render: ({badgeId, background} = {}) =>
    {group} = @state.getValue()

    background ?= if group? and not group.background \
                 then config.BACKGROUNDS[0]
                 else group?.background

    z '.z-group-header', {
      style:
        backgroundImage: if background \
          then "url(#{config.CDN_URL}/groups/backgrounds/#{background}_bg.jpg)"
          else 'none'
    },
      z '.g-grid',
        z '.badge',
          z @$groupBadge, {badgeId}
