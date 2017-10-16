z = require 'zorium'

Head = require '../../components/head'
AppBar = require '../../components/app_bar'
BottomBar = require '../../components/bottom_bar'
ButtonMenu = require '../../components/button_menu'
Stars = require '../../components/stars'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class StarsPage
  constructor: ({@model, requests, @router, serverData}) ->
    gameKey = requests.map ({route}) ->
      route.params.gameKey or config.DEFAULT_GAME_KEY

    @$head = new Head({
      @model
      requests
      serverData
      meta: {
        title: @model.l.get 'starsPage.title'
        description: @model.l.get 'starsPage.title'
      }
    })
    @$appBar = new AppBar {@model}
    @$buttonMenu = new ButtonMenu {@model}
    @$bottomBar = new BottomBar {@model, @router, requests}

    @$stars = new Stars {@model, @router, sort: 'popular', gameKey}

    @state = z.state
      windowSize: @model.window.getSize()

  renderHead: => @$head

  render: =>
    {windowSize} = @state.getValue()

    z '.p-stars', {
      style:
        height: "#{windowSize.height}px"
    },
      z @$appBar, {
        title: @model.l.get 'starsPage.title'
        isFlat: true
        $topLeftButton: z @$buttonMenu, {color: colors.$primary500}
      }
      @$stars
      @$bottomBar
