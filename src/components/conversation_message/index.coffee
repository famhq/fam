z = require 'zorium'
_defaults = require 'lodash/defaults'

Message = require '../message'

if window?
  require './index.styl'

module.exports = class ConversationMessage
  constructor: (options) ->
    {@selectedProfileDialogUser, @messageBatchesStreams, @model} = options
    @$message = new Message options

  render: ({isTextareaFocused}) =>
    z '.z-conversation-message',
      z @$message, {
        isTextareaFocused
        openProfileDialogFn: (id, user, groupUser) =>
          @selectedProfileDialogUser.next _defaults {
            groupUser: groupUser
            onDeleteMessage: =>
              @model.chatMessage.deleteById id
              .then =>
                @messageBatchesStreams.take(1).toPromise()
          }, user
      }
