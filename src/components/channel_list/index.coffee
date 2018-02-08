z = require 'zorium'
_map = require 'lodash/map'

Icon = require '../icon'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class ChannelList
  constructor: ({@model, @isOpen, conversations}) ->
    me = @model.user.getMe()

    @state = z.state
      me: me
      conversations: conversations.map (conversations) ->
        _map conversations, (channel) ->
          {
            channel
            $statusIcon: new Icon()
          }

  render: ({onclick, selectedConversationId}) =>
    {me, conversations} = @state.getValue()

    z '.z-channel-list',
      _map conversations, ({channel}) ->
        isSelected = selectedConversationId is channel.id
        z '.channel', {
          className: z.classKebab {isSelected}
          onclick: (e) ->
            onclick e, channel
        },
          z '.hashtag', '#'
          z '.info',
            z '.name', channel.data?.name
            z '.description', channel.data?.description
