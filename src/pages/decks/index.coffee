z = require 'zorium'

Head = require '../../components/head'
Decks = require '../../components/decks'

if window?
  require './index.styl'

module.exports = class DecksPage
  installMessage: 'Add Starfi.re to your homescreen to quickly access
                  these guides anytime'

  constructor: ({@model, requests, @router, serverData}) ->
    thread = requests.flatMapLatest ({route}) =>
      if route.params.id
        @model.thread.getById route.params.id
      else
        Rx.Observable.just null

    @$decks = new Decks {@model, @router, thread}

    @$head = new Head({
      @model
      requests
      serverData
      meta: {
        title: 'Decks'
        description: 'Decks'
      }
    })

    @state = z.state
      windowSize: @model.window.getSize()

  renderHead: => @$head

  render: =>
    {windowSize} = @state.getValue()

    z '.p-decks', {
      style:
        height: "#{windowSize.height}px"
    },
      @$decks
