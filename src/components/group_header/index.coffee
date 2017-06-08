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
        backgroundImage: if group?.id is config.MAIN_GROUP_ID \
          then "url(#{config.CDN_URL}/groups/covers/clash_royale.jpg?1)"
          else if group?.id is config.WITH_ZACK_GROUP_ID \
          then "url(#{config.CDN_URL}/groups/covers/withzack.jpg)"
          else if background
          then "url(#{config.CDN_URL}/groups/backgrounds/#{background}_bg.jpg)"
          else 'none'
    },
      if group?.id isnt config.MAIN_GROUP_ID
        z '.g-grid',
          z '.badge',
            z @$groupBadge, {badgeId}
