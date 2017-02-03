z = require 'zorium'

Head = require '../../components/head'
AppBar = require '../../components/app_bar'
ButtonMenu = require '../../components/button_menu'
Videos = require '../../components/videos'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class VideosPage
  constructor: ({@model, requests, @router, serverData}) ->
    @$head = new Head({
      @model
      requests
      serverData
      meta: {
        title: 'Videos'
        description: 'Videos'
      }
    })
    @$appBar = new AppBar {@model}
    @$buttonMenu = new ButtonMenu {@model}

    @$cards = new Videos {@model, @router, sort: 'popular'}

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
        title: 'Videos'
        isFlat: true
        $topLeftButton: z @$buttonMenu, {color: colors.$tertiary900}
      }
      @$cards
