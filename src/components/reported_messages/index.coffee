z = require 'zorium'
_map = require 'lodash/map'
log = require 'loga'

ConversationMessage = require '../conversation_message'
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class ReportedMessages
  constructor: ({@model, @portal, @selectedProfileDialogUser, messages}) ->
    @state = z.state
      messages: messages.map (messages) =>
        _map messages, (message) =>
          {
            $chatMessage: new ConversationMessage {
              @model, @selectedProfileDialogUser
            }
            messageInfo: message
          }

  render: =>
    {messages} = @state.getValue()

    z '.z-reported-messages',
      z '.g-grid',
        _map messages, ({messageInfo, $chatMessage}) ->
          z $chatMessage, {message: messageInfo, showModInfo: true}
