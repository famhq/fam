z = require 'zorium'

UserList = require '../user_list'
PrimaryButton = require '../primary_button'

if window?
  require './index.styl'

module.exports = class GroupMembers
  constructor: ({@model, @router, group, selectedProfileDialogUser}) ->
    @$inviteButton = new PrimaryButton()
    @$userList = new UserList {
      @model
      selectedProfileDialogUser: selectedProfileDialogUser
      users: group.map (group) ->
        group?.users
    }

    @state = z.state {
      me: @model.user.getMe()
      group
    }

  render: =>
    {me, group} = @state.getValue()

    hasPermission = @model.group.hasPermission group, me, {level: 'member'}

    z '.z-group-members',
      z '.g-grid',
        if hasPermission
          z @$inviteButton, {
            text: 'Invite members'
            onclick: =>
              @router.go "/group/#{group?.id}/invite"
          }
        @$userList
