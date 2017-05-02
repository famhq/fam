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
        title: @model.l.get 'videosPage.title'
        description: @model.l.get 'videosPage.title'
      }
    })
    @$appBar = new AppBar {@model}
    @$buttonMenu = new ButtonMenu {@model}

    @$videos = new Videos {@model, @router, sort: 'popular'}

    @state = z.state
      windowSize: @model.window.getSize()

  renderHead: => @$head

  render: =>
    {windowSize} = @state.getValue()

    z '.p-videos', {
      style:
        height: "#{windowSize.height}px"
    },
      z @$appBar, {
        title: @model.l.get 'videosPage.title'
        isFlat: true
        $topLeftButton: z @$buttonMenu, {color: colors.$tertiary900}
      }
      @$videos
