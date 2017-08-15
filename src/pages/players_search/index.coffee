z = require 'zorium'

Head = require '../../components/head'
PlayersSearch = require '../../components/players_search'
AppBar = require '../../components/app_bar'
ButtonBack = require '../../components/button_back'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class PlayersSearchPage
  hideDrawer: true

  constructor: ({@model, requests, @router, serverData}) ->
    @$head = new Head({
      @model
      requests
      serverData
      meta: {
        title: @model.l.get 'playersSearchPage.title'
        description: @model.l.get 'playersSearchPage.title'
      }
    })
    @$appBar = new AppBar {@model}
    @$buttonBack = new ButtonBack {@model, @router}
    @$playersSearch = new PlayersSearch {@model, @router, serverData}

    @state = z.state
      windowSize: @model.window.getSize()

  renderHead: => @$head

  render: =>
    {windowSize} = @state.getValue()

    z '.p-players-search', {
      style:
        height: "#{windowSize.height}px"
    },
      z @$appBar, {
        title: @model.l.get 'playersSearchPage.title'
        style: 'primary'
        isFlat: true
        $topLeftButton: z @$buttonBack, {color: colors.$primary500}
      }
      @$playersSearch
