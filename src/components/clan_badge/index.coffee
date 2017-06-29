z = require 'zorium'

ClanBadge = require '../clan_badge'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class ClanBadge
  render: ({clan, size} = {}) ->
    badgeId = clan?.badge or clan?.data?.badge

    # height = if size then "#{parseInt(size) * (40 / 34)}px" else undefined

    z '.z-clan-badge',
      style:
        width: size
        # height: height
        backgroundImage:
          if badgeId
          then "url(#{config.CDN_URL}/badges/#{badgeId}.png)"
          else 'none'
