z = require 'zorium'
_map = require 'lodash/map'

Base = require '../base'
Spinner = require '../spinner'
VideoListItem = require '../video_list_item'
UiCard = require '../ui_card'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class GroupHomeVideos extends Base
  constructor: ({@model, @router, group, player, @overlay$}) ->
    me = @model.user.getMe()

    @$spinner = new Spinner()
    @$videosUiCard = new UiCard()

    @state = z.state {
      group
      language: @model.l.getLanguage()
      $videos: group.switchMap (group) =>
        @model.video.getAllByGroupId group.id, {
          limit: 1
        }
      .map (videos) =>
        _map videos, (video) =>
          @getCached$ video.id, VideoListItem, {
            @model, @router, video
          }
    }

  beforeUnmount: ->
    super()

  render: =>
    {group, $videos} = @state.getValue()

    z '.z-group-home-videos',
      z @$videosUiCard,
        $title: @model.l.get 'groupHome.newestVideo'
        $content:
          z '.z-group-home_ui-card',
            if $videos
              _map $videos, ($video) ->
                z '.list-item',
                  z $video, {hasPadding: false}
            else
              @$spinner
        submit:
          text: @model.l.get 'groupHome.viewAllVideos'
          onclick: =>
            @model.group.goPath group, 'groupVideos', {@router}
