z = require 'zorium'

Head = require '../../components/head'
AddDeck = require '../../components/add_deck'

if window?
  require './index.styl'

module.exports = class AddDeckPage
  hideDrawer: true
  constructor: ({model, requests, @router, serverData}) ->
    @$head = new Head({
      model
      requests
      serverData
      meta: {
        title: model.l.get 'addDeckPage.title'
        description: model.l.get 'addDeckPage.title'
      }
    })
    @$addDeck = new AddDeck {model, @router}

    @state = z.state
      windowSize: model.window.getSize()

  renderHead: => @$head

  render: =>
    {windowSize} = @state.getValue()

    z '.p-add-deck', {
      style:
        height: "#{windowSize.height}px"
    },
      @$addDeck
