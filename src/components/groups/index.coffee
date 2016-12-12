z = require 'zorium'
_isEmpty = require 'lodash/isEmpty'
_map = require 'lodash/map'
FloatingActionButton = require 'zorium-paper/floating_action_button'

Icon = require '../icon'
GroupHeader = require '../group_header'
Spinner = require '../spinner'

if window?
  require './index.styl'

module.exports = class Groups
  constructor: ({@model, @router}) ->
    @$spinner = new Spinner()
    @$addIcon = new Icon()

    @$fab = new FloatingActionButton()

    @state = z.state
      me: @model.user.getMe()
      myGroups: @model.group.getAll({filter: 'mine'})
                .map (groups) ->
                  _map groups, (group) ->
                    {group, $header: new GroupHeader({group})}
      openGroups: @model.group.getAll({filter: 'open'})
                  .map (groups) ->
                    _map groups, (group) ->
                      {group, $header: new GroupHeader({group})}

  render: =>
    {me, myGroups, openGroups} = @state.getValue()

    groupTypes = [
      {
        title: 'My groups'
        groups: myGroups
      }
      {
        title: 'Open groups'
        groups: openGroups
      }
    ]

    z '.z-groups',
      _map groupTypes, ({title, groups}) =>
        z '.group-list',
          z '.g-grid',
            z 'h2.title', title
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
