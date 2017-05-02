z = require 'zorium'

Head = require '../../components/head'
AppBar = require '../../components/app_bar'
ButtonMenu = require '../../components/button_menu'
Cards = require '../../components/cards'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class CardsPage
  constructor: ({@model, requests, @router, serverData}) ->
    @$head = new Head({
      @model
      requests
      serverData
      meta: {
        title: @model.l.get 'cardsPage.title'
        description: @model.l.get 'cardsPage.title'
      }
    })
    @$appBar = new AppBar {@model}
    @$buttonMenu = new ButtonMenu {@model}

    @$cards = new Cards {@model, @router, sort: 'popular'}

    @state = z.state
      windowSize: @model.window.getSize()

  renderHead: => @$head

  render: =>
    {windowSize} = @state.getValue()

    z '.p-cards', {
      style:
        height: "#{windowSize.height}px"
    },
      z @$appBar, {
        title: @model.l.get 'cardsPage.title'
        isFlat: true
        $topLeftButton: z @$buttonMenu, {color: colors.$tertiary900}
      }
      @$cards
