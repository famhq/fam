z = require 'zorium'
_isEmpty = require 'lodash/isEmpty'
_map = require 'lodash/map'
_startCase = require 'lodash/startCase'

GroupHeader = require '../group_header'
Spinner = require '../spinner'
FormatService = require '../../services/format'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class GroupList
  constructor: ({@model, @router, groups}) ->
    @$spinner = new Spinner()
    @state = z.state
      me: @model.user.getMe()
      groups: groups.map (groups) =>
        _map groups, (group) =>
          {group, $header: new GroupHeader({@model, group})}

  render: =>
    {groups, me} = @state.getValue()

    z '.z-group-list',
      if groups and _isEmpty groups
        z '.no-groups',
          z '.g-grid',
            @model.l.get 'groupList.empty'
      else if not groups
        @$spinner
      else if groups
        z '.groups',
          z '.g-grid',
            z '.g-cols',
              _map groups, ({group, $header}) =>
                group.type ?= 'general'
                route = @router.get 'groupHome', {
                  groupId: group.key or group.id
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
                        [
                          z 'span.middot',
                            innerHTML: ' &middot; '
                          "#{FormatService.number group.userCount} "
                          @model.l.get 'general.members'
                        ]
