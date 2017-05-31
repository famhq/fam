z = require 'zorium'
Rx = require 'rx-lite'
_map = require 'lodash/map'

GroupList = require '../group_list'
Icon = require '../icon'
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class Groups
  constructor: ({@model, @router}) ->
    myGroups = @model.group.getAll({filter: 'mine'})
    publicGroup = @model.group.getById config.MAIN_GROUP_ID
    myGroupsAndPublicGroup = Rx.Observable.combineLatest(
      myGroups
      publicGroup
      (myGroups, publicGroup) ->
        (myGroups or []).concat [publicGroup]
    )
    @$myGroupList = new GroupList {
      @model
      @router
      groups: myGroupsAndPublicGroup
    }
    @$suggestedGroupsList = new GroupList {
      @model
      @router
      groups: @model.group.getAll({filter: 'suggested'})
    }

    @$unreadInvitesIcon = new Icon()
    @$unreadInvitesChevronIcon = new Icon()

    @state = z.state
      me: @model.user.getMe()

  render: =>
    {me} = @state.getValue()

    groupTypes = [
      {
        title: @model.l.get 'groups.myGroupList'
        $groupList: @$myGroupList
      }
      # {
      #   title: @model.l.get 'groups.suggestedGroupList'
      #   $groupList: @$suggestedGroupsList
      # }
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
