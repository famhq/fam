z = require 'zorium'
chartist = if window? then require 'chartist' else null # TODO

colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class GroupManageMemberRecords
  constructor: ({@model, group, user}) ->

    records = @model.groupRecord.getAllByUserIdAndGroupId {
      groupId: group.id
      userId: user.id
    }

    @state = z.state
      group: group
      user: user
      records: records

  render: =>
    {group, user, records} = @state.getValue()

    console.log records

    z '.z-group-manage-member-records',
      'Records...'
