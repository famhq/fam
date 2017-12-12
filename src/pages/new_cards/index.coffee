z = require 'zorium'

Head = require '../../components/head'
AppBar = require '../../components/app_bar'
ButtonBack = require '../../components/button_back'
NewCards = require '../../components/new_cards'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class NewCardsPage
  constructor: ({@model, requests, @router, serverData}) ->
    @$head = new Head({
      @model
      requests
      serverData
      meta: {
        title: @model.l.get 'newCardsPage.title'
        description: @model.l.get 'newCardsPage.title'
      }
    })
    @$appBar = new AppBar {@model}
    @$backButton = new ButtonBack {@model, @router}
    @$newCards = new NewCards {@model, @router}

    @state = z.state
      windowSize: @model.window.getSize()

  renderHead: => @$head

  render: =>
    {windowSize} = @state.getValue()

    z '.p-new-cards', {
      style:
        height: "#{windowSize.height}px"
    },
      z @$appBar, {
        title: @model.l.get 'newCardsPage.title'
        $topLeftButton: z @$backButton, {color: colors.$tertiary900}
      }
      @$newCards
