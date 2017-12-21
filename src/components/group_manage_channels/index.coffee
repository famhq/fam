z = require 'zorium'

ChannelList = require '../channel_list'
Icon = require '../icon'
Fab = require '../fab'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class GroupManageChannels
  constructor: ({@model, @router, group, gameKey}) ->

    @$fab = new Fab()
    @$addIcon = new Icon()
    @$channelList = new ChannelList {@model, group}

    @state = z.state {
      group
      gameKey: gameKey
      me: @model.user.getMe()
    }

  render: =>
    {me, group, gameKey} = @state.getValue()

    z '.z-group-manage-channels',
      z @$channelList, {
        onclick: (e, {id}) =>
          @router.go 'groupEditChannel', {
            id: group.id
            conversationId: id
            gameKey: gameKey
          }
      }

      z '.fab',
        z @$fab,
          colors:
            c500: colors.$primary500
          $icon: z @$addIcon, {
            icon: 'add'
            isTouchTarget: false
            color: colors.$white
          }
          onclick: =>
            @router.go 'groupNewChannel', {gameKey, id: group.id}
