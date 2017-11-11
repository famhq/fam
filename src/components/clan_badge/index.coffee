z = require 'zorium'

ClanBadge = require '../clan_badge'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class ClanBadge
  constructor: ({clan} = {}) ->
    @state = z.state
      clan: clan

  render: (props = {}) =>
    {size} = props

    {clan} = @state.getValue()
    clan ?= props.clan

    badgeId = clan?.badge or clan?.data?.badgeId % 1000

    # height = if size then "#{parseInt(size) * (40 / 34)}px" else undefined

    z '.z-clan-badge',
      style:
        width: size
        # height: height
        backgroundImage:
          if badgeId
          then "url(#{config.CDN_URL}/badges/#{badgeId}.png)"
          else 'none'
