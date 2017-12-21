z = require 'zorium'

ClanBadge = require '../clan_badge'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class GroupHeader
  constructor: ({@model, @router, @group}) ->
    @$clanBadge = new ClanBadge {@group}

    @isLoaded = @model.image.isLoaded @getBackgroundUrl @group

    @state = z.state {
      @group
    }

  afterMount: (@$$el) =>
    unless @isLoaded
      load = (group) =>
        @model.image.load @getBackgroundUrl group
        .then =>
          # don't want to re-render entire state every time a pic loads in
          @$$el?.classList.add 'is-loaded'
          @isLoaded = true
      if @group.take
        @group.take(1).subscribe load
      else
        load @group

  getBackgroundUrl: (group) ->
    if group? and not group.background \
    then 'https://cdn.wtf/d/images/starfire/groups/backgrounds/red_bg.jpg'
    else group?.background

  render: ({badgeId, background} = {}) =>
    {group} = @state.getValue()

    background ?= @getBackgroundUrl group

    z '.z-group-header', {
      key: "group-header-#{group?.id}"
      className: z.classKebab {@isLoaded}
      style:
        backgroundImage: if background \
                          then "url(#{background})"
                          else 'none'
    },
      if group?.clan
        z '.g-grid',
          z '.badge',
            z @$clanBadge, {clan: group?.clan}
