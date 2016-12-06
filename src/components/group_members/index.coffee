_ = require 'lodash'
z = require 'zorium'
log = require 'loga'
Rx = require 'rx-lite'

UserList = require '../user_list'
config = require '../../config'

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
