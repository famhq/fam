z = require 'zorium'
Rx = require 'rx-lite'
colors = require '../../colors'
_isEmpty = require 'lodash/isEmpty'
log = require 'loga'
moment = require 'moment'

config = require '../../config'
Icon = require '../icon'
Spinner = require '../spinner'
UserList = require '../user_list'

if window?
  require './index.styl'

module.exports = class Friends
  constructor: ({@model, users, selectedProfileDialogUser}) ->
    @$spinner = new Spinner()
    @$friendsIcon = new Icon()

    @$userList = new UserList {
      @model, users, selectedProfileDialogUser
    }

    @state = z.state
      users: users

  render: ({noFriendsMessage} = {}) =>
    {users} = @state.getValue()

    z '.z-friends',
      if users and _isEmpty users
        z '.no-friends',
          z @$friendsIcon,
            icon: 'friend'
            size: '100px'
            color: colors.$black12
          noFriendsMessage
      else if users
        z '.users',
          @$userList
      else
        @$spinner
