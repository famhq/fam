z = require 'zorium'

ClanBadge = require '../clan_badge'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class GroupHeader
  constructor: ({@model, @router, group}) ->
    @$clanBadge = new ClanBadge {group}
    @state = z.state {group}

  render: ({badgeId, background} = {}) =>
    {group} = @state.getValue()

    background ?= if group? and not group.background \
         then 'https://cdn.wtf/d/images/starfire/groups/backgrounds/red_bg.jpg'
         else group?.background

    z '.z-group-header', {
      style:
        backgroundImage: if background \
                          then "url(#{background})"
                          else 'none'
    },
      if group?.clan
        z '.g-grid',
          z '.badge',
            z @$clanBadge, {clan: group?.clan}
