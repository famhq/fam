z = require 'zorium'
isUuid = require 'isuuid'

AppBar = require '../../components/app_bar'
GroupVideos = require '../../components/group_videos'
ButtonMenu = require '../../components/button_menu'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class GroupVideosPage
  isGroup: true

  constructor: ({@model, requests, @router, serverData, group}) ->
    @$appBar = new AppBar {@model}
    @$buttonMenu = new ButtonMenu {@model, @router}
    @$groupVideos = new GroupVideos {
      @model, @router, serverData, group
    }

    @state = z.state
      windowSize: @model.window.getSize()

  getMeta: =>
    {
      title: @model.l.get 'videosPage.title'
      description: @model.l.get 'videosPage.title'
    }

  render: =>
    {windowSize} = @state.getValue()

    z '.p-group-videos', {
      style:
        height: "#{windowSize.height}px"
    },
      z @$appBar, {
        title: @model.l.get 'videosPage.title'
        $topLeftButton: z @$buttonMenu, {
          color: colors.$header500Icon
        }
      }
      @$groupVideos
