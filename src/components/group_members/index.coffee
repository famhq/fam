z = require 'zorium'

UserList = require '../user_list'

if window?
  require './index.styl'

module.exports = class GroupMembers
  constructor: ({@model, @router, group, selectedProfileDialogUser}) ->
    @$userList = new UserList {
      @model
      selectedProfileDialogUser: selectedProfileDialogUser
      users: group.map ({users}) ->
        users
    }

    @state = z.state {}

  render: =>
    {} = @state.getValue()

    z '.z-group-members',
      @$userList
