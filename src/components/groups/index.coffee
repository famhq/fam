z = require 'zorium'
Rx = require 'rx-lite'
moment = require 'moment'
colors = require '../../colors'
_isEmpty = require 'lodash/lang/isEmpty'
_ = require 'lodash'
log = require 'loga'
Dialog = require 'zorium-paper/dialog'
FloatingActionButton = require 'zorium-paper/floating_action_button'

config = require '../../config'
colors = require '../../colors'
Icon = require '../icon'
PrimaryButton = require '../primary_button'
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
      myGroups: @model.group.getAll().map (groups) ->
        _.map groups, (group) ->
          {group, $header: new GroupHeader({group})}

  render: =>
    {me, myGroups} = @state.getValue()

    z '.z-groups',
      z '.g-grid',
        z 'h2.title', 'My groups'
      if myGroups and _.isEmpty myGroups
        z '.no-groups',
          z '.g-grid',
            'No groups found'
      else if myGroups
        z '.groups',
          z '.g-grid',
            z '.g-cols',
              _.map myGroups, ({group, $header}) =>
                z '.g-col.g-xs-6.g-md-3',
                  @router.link z 'a.group', {
                    href: "/group/#{group.id}"
                  },
                    z '.header',
                      z '.inner',
                        $header
                    z '.content',
                      z '.name', group.name or 'Nameless'
                      z '.count', "#{group.members?.length} members"
