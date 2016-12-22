z = require 'zorium'

Conversation = require '../conversation'

if window?
  require './index.styl'

module.exports = class GroupChat
  constructor: (options) ->
    {@model, @router, conversation,
      selectedProfileDialogUser, isActive} = options

    @$conversation = new Conversation {
      @model
      @router
      selectedProfileDialogUser
      isActive
      conversation
      scrollYOnly: true
    }

    @state = z.state {}

  render: =>
    {} = @state.getValue()

    z '.z-group-chat',
      z @$conversation
