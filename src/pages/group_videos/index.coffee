z = require 'zorium'
isUuid = require 'isuuid'

Head = require '../../components/head'
AppBar = require '../../components/app_bar'
GroupVideos = require '../../components/group_videos'
ButtonMenu = require '../../components/button_menu'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class GroupVideosPage
  isGroup: true

  constructor: ({@model, requests, @router, serverData, group}) ->
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
    @$buttonMenu = new ButtonMenu {@model, @router}
    @$groupVideos = new GroupVideos {
      @model, @router, serverData, group
    }

    @state = z.state
      windowSize: @model.window.getSize()

  renderHead: => @$head

  render: =>
    {windowSize} = @state.getValue()

    z '.p-group-videos', {
      style:
        height: "#{windowSize.height}px"
    },
      z @$appBar, {
        title: @model.l.get 'videosPage.title'
        $topLeftButton: z @$buttonMenu, {
          color: colors.$primary500
        }
      }
      @$groupVideos
