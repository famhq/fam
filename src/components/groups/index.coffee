z = require 'zorium'
_map = require 'lodash/map'

GroupList = require '../group_list'
Icon = require '../icon'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class Groups
  constructor: ({@model, @router}) ->
    @$myGroupList = new GroupList {
      @router
      groups: @model.group.getAll({filter: 'mine'})
    }
    @$openGroupList = new GroupList {
      @router
      groups: @model.group.getAll({filter: 'open'})
    }

    @$unreadInvitesIcon = new Icon()
    @$unreadInvitesChevronIcon = new Icon()

    @state = z.state
      me: @model.user.getMe()

  render: =>
    {me} = @state.getValue()

    groupTypes = [
      {
        title: 'My groups'
        $groupList: @$myGroupList
      }
      {
        title: 'Open groups'
        $groupList: @$openGroupList
      }
    ]

    unreadGroupInvites = me?.data.unreadGroupInvites
    inviteStr = if unreadGroupInvites is 1 then 'invite' else 'invites'

    z '.z-groups',
      if unreadGroupInvites
        @router.link z 'a.unread-invites', {
          href: '/groupInvites'
        },
          z '.icon',
            z @$unreadInvitesIcon,
              icon: 'notifications'
              isTouchTarget: false
              color: colors.$tertiary500
          z '.text', "You have #{unreadGroupInvites} new group #{inviteStr}"
          z '.chevron',
            z @$unreadInvitesChevronIcon,
              icon: 'chevron-right'
              isTouchTarget: false
              color: colors.$primary500
      _map groupTypes, ({title, $groupList}) ->
        z '.group-list',
          z '.g-grid',
            z 'h2.title', title
          $groupList
