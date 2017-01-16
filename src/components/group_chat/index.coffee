z = require 'zorium'

Conversation = require '../conversation'

if window?
  require './index.styl'

module.exports = class GroupChat
  constructor: (options) ->
    {@model, @router, conversation, overlay$, toggleIScroll
      selectedProfileDialogUser, isActive} = options

    @$conversation = new Conversation {
      @model
      @router
      selectedProfileDialogUser
      isActive
      toggleIScroll
      conversation
      overlay$
      scrollYOnly: true
      isGroup: true
    }

  render: =>
    z '.z-group-chat',
      z @$conversation
