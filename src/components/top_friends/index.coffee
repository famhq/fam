z = require 'zorium'
_isEmpty = require 'lodash/isEmpty'

UserList = require '../user_list'

if window?
  require './index.styl'

module.exports = class TopFriends
  constructor: ({@model, users, selectedProfileDialogUser}) ->

    userData = @model.userFollower.getAllFollowingIds()
    following = userData.map ({following}) ->
      following or []

    @$userList = new UserList {
      @model, users: following, selectedProfileDialogUser
    }

    @state = z.state
      users: following

  render: ({onclick} = {}) =>
    {users} = @state.getValue()

    z '.z-top-friends',
      if users and not _isEmpty users
        z '.users',
          z 'h2.title', 'Friends'
          z @$userList, {onclick}
