z = require 'zorium'

Conversation = require '../conversation'

if window?
  require './index.styl'

module.exports = class GroupChat
  constructor: (options) ->
    {@model, @router, conversation, overlay$, group, isLoading, gameKey
      selectedProfileDialogUser} = options

    @$conversation = new Conversation {
      @model
      @router
      selectedProfileDialogUser
      conversation
      group
      overlay$
      gameKey
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
