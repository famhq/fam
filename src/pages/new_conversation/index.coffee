z = require 'zorium'

NewConversation = require '../../components/new_conversation'

if window?
  require './index.styl'

module.exports = class NewConversationPage
  hideDrawer: true

  constructor: ({@model, requests, @router, serverData, group}) ->
    @$newConversation = new NewConversation {
      @model, @router, serverData, group
    }

    @state = z.state
      windowSize: @model.window.getSize()

  getMeta: =>
    {
      title: @model.l.get 'newConversationPage.title'
      description: @model.l.get 'newConversationPage.title'
    }

  render: =>
    {windowSize} = @state.getValue()

    z '.p-new-conversation', {
      style:
        height: "#{windowSize.height}px"
    },
      @$newConversation
