z = require 'zorium'
Rx = require 'rx-lite'
colors = require '../../colors'
log = require 'loga'

config = require '../../config'
FindFriends = require '../find_friends'

if window?
  require './index.styl'

module.exports = class NewConversation
  constructor: ({@model, @router}) ->
    @$findFriends = new FindFriends {@model}

  render: ({noNewConversationMessage} = {}) =>
    z '.z-new-conversation',
      z @$findFriends, {
        onBack: =>
          @router.back()
        onclick: (user) =>
          @model.conversation.create {
            userIds: [user.id]
          }
          .then (conversation) =>
            @router.go "/conversation/#{conversation.id}"
      }
