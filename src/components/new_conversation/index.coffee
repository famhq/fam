z = require 'zorium'

FindFriends = require '../find_friends'

if window?
  require './index.styl'

module.exports = class NewConversation
  constructor: ({@model, @router}) ->
    @$findFriends = new FindFriends {@model}

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
              @router.go "/conversation/#{conversation.id}"
      }
