z = require 'zorium'

Head = require '../../components/head'
NewThread = require '../../components/new_thread'

if window?
  require './index.styl'

module.exports = class NewThreadPage
  constructor: ({model, requests, @router, serverData}) ->
    category = requests.map ({route}) ->
      route.params.category

    @$head = new Head({
      model
      requests
      serverData
      meta: {
        title: model.l.get 'newThreadPage.title'
        description: model.l.get 'newThreadPage.title'
      }
    })
    @$newThread = new NewThread {model, @router, category}

    @state = z.state
      windowSize: model.window.getSize()

  renderHead: => @$head

  render: =>
    {windowSize} = @state.getValue()

    z '.p-new-thread', {
      style:
        height: "#{windowSize.height}px"
    },
      @$newThread
