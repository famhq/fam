z = require 'zorium'
Rx = require 'rx-lite'

Head = require '../../components/head'
AppBar = require '../../components/app_bar'
ButtonMenu = require '../../components/button_menu'
Decks = require '../../components/decks_new'
BottomBar = require '../../components/bottom_bar'

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

    @$appBar = new AppBar {@model}
    @$buttonMenu = new ButtonMenu {@model, @router}
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
    @$bottomBar = new BottomBar {@model, @router, requests}

    @state = z.state
      windowSize: @model.window.getSize()

  renderHead: => @$head

  render: =>
    {windowSize} = @state.getValue()

    z '.p-decks', {
      style:
        height: "#{windowSize.height}px"
    },
      z @$appBar,
        isFlat: true
        $topLeftButton: @$buttonMenu
        title: ''
      @$decks
      @$bottomBar
