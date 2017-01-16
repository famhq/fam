z = require 'zorium'
moment = require 'moment'
Rx = require 'rx-lite'

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

    overlay$ = new Rx.BehaviorSubject null

    @$general = new GroupManageMemberGeneral {@model, group, user}
    @$records = new GroupManageMemberRecords {@model, group, user, overlay$}
    @$notes = new GroupManageMemberNotes {@model, group, user}
    @$tabs = new Tabs {@model}

    @state = z.state
      group: group
      user: user
      overlay$: overlay$
      windowSize: @model.window.getSize()
      appBarHeight: @model.window.getAppBarHeight()

  render: =>
    {group, user, overlay$, windowSize, appBarHeight} = @state.getValue()

    z '.z-group-manage-member', {
      style:
        height: "#{windowSize.height - appBarHeight}px"
    },
      z @$userHeader, {user: user}
      z '.content', {
        style:
          height: "#{windowSize.height - appBarHeight}px"
      },
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
            # {
            #   $menuText: 'General'
            #   $el: @$general
            # }
            {
              $menuText: 'Records'
              $el: @$records
            }
            {
              $menuText: 'Notes'
              $el: @$notes
            }
          ]

      overlay$
