z = require 'zorium'

UserSearch = require '../user_search'

if window?
  require './index.styl'

module.exports = class NewConversation
  constructor: ({@model, @router}) ->
    @$findFriends = new UserSearch {@model}

    @state = z.state
      isLoading: false

  render: ({noNewConversationMessage} = {}) =>
    {isLoading} = @state.getValue()

    z '.z-new-conversation',
      z @$findFriends, {
        showCurrentFriends: true
        onBack: =>
          @router.back()
        onclick: (user) =>
          unless isLoading
            @state.set isLoading: true
            @model.conversation.create {
              userIds: [user.id]
            }
            .then (conversation) =>
              @state.set isLoading: false
              @router.go 'conversation', {groupId: conversation.id}
      }
