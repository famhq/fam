z = require 'zorium'
_map = require 'lodash/map'

Base = require '../base'
Spinner = require '../spinner'
UiCard = require '../ui_card'
FormatService = require '../../services/format'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class GroupHomeChat
  constructor: ({@model, @router, group, player, @overlay$}) ->
    me = @model.user.getMe()

    @$spinner = new Spinner()
    @$uiCard = new UiCard()

    @state = z.state {
      group
      groupUsersOnline: group.switchMap (group) =>
        @model.groupUser.getOnlineCountByGroupId group.id
    }

  render: =>
    {group, groupUsersOnline} = @state.getValue()

    z '.z-group-home-chat',
      z @$uiCard,
        $title: @model.l.get 'general.chat'
        $content:
          z '.z-group-home_ui-card',
            @model.l.get 'groupHome.peopleInChat', {
              replacements:
                count: FormatService.number(groupUsersOnline or 0)
            }
        submit:
          text: @model.l.get 'earnXp.dailyChatMessageButton'
          onclick: =>
            @router.go 'groupChat', {groupId: group.key or group.id}
