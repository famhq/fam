z = require 'zorium'

Head = require '../../components/head'
NewDeck = require '../../components/new_deck'

if window?
  require './index.styl'

module.exports = class NewDeckPage
  constructor: ({model, requests, @router, serverData}) ->
    @$head = new Head({
      model
      requests
      serverData
      meta: {
        title: 'New Deck'
        description: 'New Deck'
      }
    })
    @$newDeck = new NewDeck {model, @router}

    @state = z.state
      windowSize: @model.window.getSize()

  renderHead: => @$head

  render: =>
    {windowSize} = @state.getValue()

    z '.p-new-deck', {
      style:
        height: "#{windowSize.height}px"
    },
      @$newDeck
