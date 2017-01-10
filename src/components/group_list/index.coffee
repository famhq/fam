z = require 'zorium'
_isEmpty = require 'lodash/isEmpty'
_map = require 'lodash/map'

GroupHeader = require '../group_header'

if window?
  require './index.styl'

module.exports = class Groups
  constructor: ({@router, groups}) ->
    @state = z.state
      groups: groups.map (groups) ->
        _map groups, (group) ->
          {group, $header: new GroupHeader({group})}

  render: =>
    {groups} = @state.getValue()

    z '.z-group-list',
      if groups and _isEmpty groups
        z '.no-groups',
          z '.g-grid',
            'No groups found'
      else if groups
        z '.groups',
          z '.g-grid',
            z '.g-cols',
              _map groups, ({group, $header}) =>
                z '.g-col.g-xs-6.g-md-3',
                  @router.link z 'a.group', {
                    href: "/group/#{group.id}"
                  },
                    z '.header',
                      z '.inner',
                        $header
                    z '.content',
                      z '.name', group.name or 'Nameless'
                      z '.count', "#{group.userIds?.length} members"
