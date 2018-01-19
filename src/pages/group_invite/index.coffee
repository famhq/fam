z = require 'zorium'
isUuid = require 'isuuid'

GroupInvite = require '../../components/group_invite'

if window?
  require './index.styl'

module.exports = class GroupInvitePage
  hideDrawer: true
  isGroup: true

  constructor: ({@model, requests, @router, serverData, group}) ->
    @$groupInvite = new GroupInvite {@model, @router, serverData, group}

    @state = z.state
      windowSize: @model.window.getSize()

  getMeta: =>
    {
      title: @model.l.get 'groupInvitePage.title'
      description: @model.l.get 'groupInvitePage.title'
    }

  render: =>
    {windowSize} = @state.getValue()

    z '.p-group-invite', {
      style:
        height: "#{windowSize.height}px"
    },
      @$groupInvite
