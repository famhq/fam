z = require 'zorium'
Rx = require 'rx-lite'

Conversation = require '../conversation'

if window?
  require './index.styl'

module.exports = class GroupChat
  constructor: (options) ->
    {@model, @router, conversation, overlay$, group, isLoading
      selectedProfileDialogUser} = options

    @$conversation = new Conversation {
      @model
      @router
      selectedProfileDialogUser
      conversation
      overlay$
      isLoading: isLoading
      isGroup: true
    }

    @state = z.state {
      group
      conversation
    }

  render: =>
    {group, conversation} = @state.getValue()

    z '.z-group-chat',
      z @$conversation
