z = require 'zorium'
_isEmpty = require 'lodash/isEmpty'
_map = require 'lodash/map'
_startCase = require 'lodash/startCase'

GroupHeader = require '../group_header'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class GroupList
  constructor: ({@model, @router, groups, gameKey}) ->
    @state = z.state
      me: @model.user.getMe()
      gameKey: gameKey
      groups: groups.map (groups) ->
        _map groups, (group) ->
          {group, $header: new GroupHeader({group})}

  render: =>
    {groups, me, gameKey} = @state.getValue()

    z '.z-group-list',
      if groups and _isEmpty groups
        z '.no-groups',
          z '.g-grid',
            @model.l.get 'groupList.empty'
      else if groups
        z '.groups',
          z '.g-grid',
            z '.g-cols',
              _map groups, ({group, $header}) =>
                group.type ?= 'general'
                hasMemberPermission = @model.group.hasPermission group, me, {
                  level: 'member'
                }
                if hasMemberPermission
                  route = @router.get 'groupChat', {
                    gameKey, id: group.key or group.id
                  }
                else
                  route = @router.get 'group', {
                    gameKey, id: group.key or group.id
                  }
                z '.g-col.g-xs-12.g-md-6',
                  @router.link z 'a.group', {
                    href: route
                  },
                    z '.header',
                      z '.inner',
                        $header
                    z '.content',
                      z '.name', group.name or 'Nameless'
                      z '.count',
                        @model.l.get "groupList.type#{_startCase(group.type)}"
                        if group.type isnt 'public'
                          [
                            z 'span.middot',
                              innerHTML: ' &middot; '
                            "#{group.userIds?.length} "
                            @model.l.get 'general.members'
                          ]
