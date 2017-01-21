z = require 'zorium'

UserList = require '../user_list'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class EventMembers
  constructor: ({@model, event, selectedProfileDialogUser}) ->

    @$userList = new UserList {
      @model
      users: event.map (event) ->
        event.users
      selectedProfileDialogUser
    }

    @state = z.state
      event: event

  render: =>
    {event} = @state.getValue()

    z '.z-event-members',
      z '.g-grid',
        @$userList
