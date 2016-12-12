z = require 'zorium'

GroupBadge = require '../group_badge'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class GroupBadge
  constructor: ({@model, group}) ->
    @state = z.state {group}

  render: ({badgeId, onclick} = {}) =>
    {group} = @state.getValue()

    badgeId ?= group?.badgeId

    z '.z-group-badge', {onclick},
      z '.overlay',
        style:
          backgroundImage:
            "url(#{config.CDN_URL}/groups/badges/badge_frame.png)"
      z '.inner',
        style:
          backgroundImage:
            "url(#{config.CDN_URL}/groups/badges/#{badgeId}.png)"
