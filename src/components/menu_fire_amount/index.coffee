z = require 'zorium'

FormatService = require '../../services/format'
colors = require '../../colors'

if window?
  require './index.styl'

Icon = require '../icon'

module.exports = class MenuFireAmount
  constructor: ({@model, @router, group}) ->
    @$fireIcon = new Icon()

    @state = z.state
      me: @model.user.getMe()
      group: group

  render: =>
    {me, group} = @state.getValue()

    z '.z-menu-fire-amount', {
      onclick: =>
        @router.go 'groupFire', {groupId: group?.id}
    },
      FormatService.number me?.fire
      z '.icon',
        z @$fireIcon,
          icon: 'fire'
          color: colors.$quaternary500
          isTouchTarget: false
          size: '20px'
