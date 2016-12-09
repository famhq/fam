z = require 'zorium'
log = require 'loga'
Rx = require 'rx-lite'

Conversation = require '../conversation'
config = require '../../config'

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
