z = require 'zorium'
moment = require 'moment'

Tabs = require '../tabs'
UserHeader = require '../user_header'
GroupManageMemberGeneral = require '../group_manage_member_general'
GroupManageMemberRecords = require '../group_manage_member_records'
GroupManageMemberNotes = require '../group_manage_member_notes'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class GroupManageMember
  constructor: ({@model, @router, group, user}) ->
    @$userHeader = new UserHeader()

    @$general = new GroupManageMemberGeneral {@model, group, user}
    @$records = new GroupManageMemberRecords {@model, group, user}
    @$notes = new GroupManageMemberNotes {@model, group, user}
    @$tabs = new Tabs {@model}

    @state = z.state
      group: group
      user: user

  render: =>
    {group, user} = @state.getValue()

    z '.z-group-manage-member',
      z @$userHeader, {user: user}
      z '.info',
        z '.g-grid',
          z '.flex',
            z '.name', @model.user.getDisplayName user
            z '.join-date',
              z '.title', 'Joined'
              z '.date', moment(user?.joinTime).format 'MMM D, YYYY'

      z @$tabs,
        isBarFixed: false
        fitToParent: true
        barBgColor: colors.$tertiary700
        barInactiveColor: colors.$white
        tabs: [
          {
            $menuText: 'General'
            $el: @$general
          }
          {
            $menuText: 'Records'
            $el: @$records
          }
          {
            $menuText: 'Notes'
            $el: @$notes
          }
        ]
