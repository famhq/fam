z = require 'zorium'

Head = require '../../components/head'
NewConversation = require '../../components/new_conversation'

if window?
  require './index.styl'

module.exports = class NewConversationPage
  hideDrawer: true

  constructor: ({model, requests, @router, serverData}) ->
    group = requests.switchMap ({route}) ->
      model.group.getById route.params.id
    gameKey = requests.map ({route}) ->
      route.params.gameKey or config.DEFAULT_GAME_KEY

    @$head = new Head({
      model
      requests
      serverData
      meta: {
        title: model.l.get 'newConversationPage.title'
        description: model.l.get 'newConversationPage.title'
      }
    })
    @$newConversation = new NewConversation {
      model, @router, serverData, group, gameKey
    }

    @state = z.state
      windowSize: model.window.getSize()

  renderHead: => @$head

  render: =>
    {windowSize} = @state.getValue()

    z '.p-new-conversation', {
      style:
        height: "#{windowSize.height}px"
    },
      @$newConversation
