z = require 'zorium'

GroupBadge = require '../group_badge'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class GroupBadge
  constructor: ({@model, group}) ->
    @state = z.state {group}

  render: ({badgeId, onclick, isRound} = {}) =>
    {group} = @state.getValue()

    badgeId ?= group?.badgeId

    z '.z-group-badge', {
      onclick
      className: z.classKebab {isRound}
    },
      if group?.badge
        z '.image',
          style:
            backgroundImage: "url(#{group?.badge})"
      else
        [
          z '.overlay',
            style:
              backgroundImage:
                "url(#{config.CDN_URL}/groups/badges/badge_frame.png)"
          z '.inner',
            style:
              backgroundImage:
                if badgeId
                then "url(#{config.CDN_URL}/groups/badges/#{badgeId}.png)"
                else 'none'
        ]
