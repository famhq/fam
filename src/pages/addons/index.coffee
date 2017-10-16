z = require 'zorium'

Head = require '../../components/head'
AppBar = require '../../components/app_bar'
BottomBar = require '../../components/bottom_bar'
ButtonMenu = require '../../components/button_menu'
AddOns = require '../../components/addons'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class AddOnsPage
  constructor: ({@model, requests, @router, serverData}) ->
    gameKey = requests.map ({route}) ->
      route.params.gameKey or config.DEFAULT_GAME_KEY
    @$head = new Head({
      @model
      requests
      serverData
      meta: {
        title: @model.l.get 'addonsPage.title'
        description: @model.l.get 'addonsPage.title'
      }
    })
    @$appBar = new AppBar {@model}
    @$buttonMenu = new ButtonMenu {@model}
    @$bottomBar = new BottomBar {@model, @router, requests}

    @$addons = new AddOns {@model, @router, sort: 'popular', gameKey}

    @state = z.state
      windowSize: @model.window.getSize()

  renderHead: => @$head

  render: =>
    {windowSize} = @state.getValue()

    z '.p-addons', {
      style:
        height: "#{windowSize.height}px"
    },
      z @$appBar, {
        title: @model.l.get 'addonsPage.title'
        isFlat: true
        $topLeftButton: z @$buttonMenu, {color: colors.$primary500}
      }
      @$addons
      @$bottomBar
