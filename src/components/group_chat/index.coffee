z = require 'zorium'

Conversation = require '../conversation'

if window?
  require './index.styl'

module.exports = class GroupChat
  constructor: ({@model, @router, conversation, selectedProfileDialogUser}) ->
    @$conversation = new Conversation {
      @model
      @router
      selectedProfileDialogUser
      conversation
    }

    @state = z.state {}

  render: =>
    {} = @state.getValue()

    z '.z-group-chat',
      z @$conversation
