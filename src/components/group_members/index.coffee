z = require 'zorium'
_filter = require 'lodash/filter'

UserList = require '../user_list'
PrimaryButton = require '../primary_button'

if window?
  require './index.styl'

module.exports = class GroupMembers
  constructor: (options) ->
    {@model, @router, group, selectedProfileDialogUser, gameKey} = options

    onlineUsers = group.map (group) ->
      _filter group?.users, ({isOnline}) ->
        isOnline
    @$onlineUsersList = new UserList {
      @model
      selectedProfileDialogUser: selectedProfileDialogUser
      users: onlineUsers
    }

    allUsers = group.map (group) ->
      group?.users
    @$allUsersList = new UserList {
      @model
      selectedProfileDialogUser: selectedProfileDialogUser
      users: allUsers
    }

    @$addRecordsButton = new PrimaryButton()

    @state = z.state {
      me: @model.user.getMe()
      group: group
      gameKey: gameKey
      onlineUsersCount: onlineUsers.map (users) -> users?.length
      allUsersCount: allUsers.map (users) -> users?.length
    }

  render: =>
    {me, group, onlineUsersCount, allUsersCount} = @state.getValue()

    onlineUsersCount ?= 0
    allUsersCount ?= 0
    hasAdminPermission = @model.group.hasPermission group, me, {level: 'admin'}

    z '.z-group-members',
      z '.g-grid',
        if hasAdminPermission
          z @$addRecordsButton, {
            text: 'Add records'
            onclick: =>
              @router.go 'groupAddRecords', {gameKey, id: group?.id}
          }
        z 'h2.title',
          'Online'
          z 'span', innerHTML: ' &middot; '
          onlineUsersCount
        @$onlineUsersList

        z 'h2.title',
          'All members'
          z 'span', innerHTML: ' &middot; '
          allUsersCount
        @$allUsersList
