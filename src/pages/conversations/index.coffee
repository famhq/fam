z = require 'zorium'

Head = require '../../components/head'
AppBar = require '../../components/app_bar'
ButtonMenu = require '../../components/button_menu'
Conversations = require '../../components/conversations'

if window?
  require './index.styl'

module.exports = class ConversationsPage
  constructor: ({@model, requests, @router, serverData}) ->
    @$head = new Head({
      @model
      requests
      serverData
      meta: {
        title: @model.l.get 'general.conversations'
        description: @model.l.get 'general.conversations'
      }
    })
    @$appBar = new AppBar {@model}
    @$buttonMenu = new ButtonMenu {@model, @router}
    @$conversations = new Conversations {@model, @router}

    @state = z.state
      windowSize: @model.window.getSize()

  renderHead: => @$head

  render: =>
    {windowSize} = @state.getValue()

    z '.p-conversations', {
      style:
        height: "#{windowSize.height}px"
    },
      z @$appBar,
        isFlat: true
        $topLeftButton: @$buttonMenu
        title: @model.l.get 'general.conversations'
      @$conversations
