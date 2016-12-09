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

module.exports = class TopFriends
  constructor: ({@model, users, selectedProfileDialogUser}) ->
    @$spinner = new Spinner()

    userData = @model.userData.getMe {
      embed: ['following']
    }
    following = userData.map ({following}) ->
      following or []

    @$userList = new UserList {
      @model, users: following, selectedProfileDialogUser
    }

    @state = z.state
      users: following

  render: =>
    {users} = @state.getValue()

    z '.z-top-friends',
      if users and not _isEmpty users
        z '.users',
          z 'h2.title', 'Friends'
          @$userList
