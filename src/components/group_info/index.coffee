z = require 'zorium'

GroupHeader = require '../group_header'
PrimaryButton = require '../primary_button'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class GroupInfo
  constructor: ({@model, @router, group}) ->
    @$groupHeader = new GroupHeader {group}
    @$joinButton = new PrimaryButton()

    @state = z.state {
      group
      me: @model.user.getMe()
      isJoinLoading: false
    }

  join: (group) =>
    @state.set isJoinLoading: true
    @model.group.joinById group.id
    .catch -> null
    .then =>
      @state.set isJoinLoading: false

  render: =>
    {me, group, isJoinLoading} = @state.getValue()

    isInGroup = @model.group.hasPermission group, me

    z '.z-group-info',
      @$groupHeader

      z '.g-grid',
        unless isInGroup
          z '.join-button',
            z @$joinButton,
              text: if isJoinLoading then 'Loading...' else 'Join group'
              onclick: =>
                unless isJoinLoading
                  @join group

        z 'h2.title', 'About'
        z '.about', group?.description

        z '.stats',
          z @$membersIcon,
            icon: 'friends'
            color: colors.$tertiary500
