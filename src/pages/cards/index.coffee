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
        title: 'Battle Cards'
        description: 'Battle Cards'
      }
    })
    @$appBar = new AppBar {@model}
    @$buttonMenu = new ButtonMenu {@model}

    @$cards = new Cards {@model, @router, sort: 'popular'}

  renderHead: => @$head

  render: =>
    z '.p-cards', {
      style:
        height: "#{window?.innerHeight}px"
    },
      z @$appBar, {
        title: 'Battle Cards'
        isFlat: true
        $topLeftButton: z @$buttonMenu, {color: colors.$tertiary900}
      }
      @$cards
