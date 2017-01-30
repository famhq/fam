z = require 'zorium'
colors = require '../../colors'
_isEmpty = require 'lodash/isEmpty'
_filter = require 'lodash/filter'

Icon = require '../icon'
Spinner = require '../spinner'
UserList = require '../user_list'

if window?
  require './index.styl'

module.exports = class Friends
  constructor: ({@model, users, selectedProfileDialogUser}) ->
    @$spinner = new Spinner()
    @$friendsIcon = new Icon()

    onlineUsers = users.map (users) ->
      _filter users, 'isOnline'

    @$onineUsersList = new UserList {
      @model, users: onlineUsers, selectedProfileDialogUser
    }

    @$allUsersList = new UserList {
      @model, users, selectedProfileDialogUser
    }

    @state = z.state
      users: users
      onlineUsersCount: onlineUsers.map (users) -> users?.length
      usersCount: users.map (users) -> users?.length

  render: ({noFriendsMessage} = {}) =>
    {users, onlineUsersCount, usersCount} = @state.getValue()

    z '.z-friends',
      if users and _isEmpty users
        z '.no-friends',
          z @$friendsIcon,
            icon: 'friend'
            size: '100px'
            color: colors.$black12
          noFriendsMessage
      else if users
        z '.g-grid',
          z 'h2.title',
            'Online'
            z 'span', innerHTML: ' &middot; '
            onlineUsersCount
          @$onlineUsersList

          z 'h2.title',
            'All'
            z 'span', innerHTML: ' &middot; '
            usersCount
          @$allUsersList
      else
        @$spinner
