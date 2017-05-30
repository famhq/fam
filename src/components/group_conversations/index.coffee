z = require 'zorium'
_map = require 'lodash/map'
_filter = require 'lodash/filter'

GroupList = require '../group_list'
Icon = require '../icon'
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class GroupConversations
  constructor: ({@model, @router}) ->

    @state = z.state
      me: @model.user.getMe()
      myGroups: @model.group.getAll({filter: 'mine'})
      publicGroup: @model.group.getById config.MAIN_GROUP_ID

  render: =>
    {me, myGroups, publicGroup} = @state.getValue()

    groups = _filter [publicGroup].concat myGroups
    console.log groups

    z '.z-group-conversations',
      _map groups, (group) ->
        z '.g-grid',
          z 'h2.title', group.name
          _map group.conversations, (conversation) ->
            z '.conversation', {
              onclick: =>
                @router.go "/group/#{group.id}/channel/#{conversation.id}"
            },
              z '.name', conversation.name
