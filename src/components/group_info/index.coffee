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
    {me} = @state.getValue()

    @model.signInDialog.openIfGuest me
    .then =>
      @state.set isJoinLoading: true

      unless localStorage?['isPushTokenStored']
        @model.pushNotificationSheet.open()

      @model.group.joinById group.id
      .catch -> null
      .then =>
        @state.set isJoinLoading: false
        @router.go "/group/#{group.id}/chat"

  render: =>
    {me, group, isJoinLoading} = @state.getValue()

    isInGroup = @model.group.hasPermission group, me

    z '.z-group-info',
      @$groupHeader

      z '.g-grid',
        unless isInGroup
          z '.join-button',
            z @$joinButton,
              text: if isJoinLoading \
                    then @model.l.get 'general.loading'
                    else @model.l.get 'joinButtonText'
              onclick: =>
                unless isJoinLoading
                  @join group

        z 'h2.title', @model.l.get 'groupInfo.title'
        z '.about', group?.description

        z '.stats',
          z @$membersIcon,
            icon: 'friends'
            color: colors.$tertiary500
