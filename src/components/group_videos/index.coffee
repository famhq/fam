z = require 'zorium'
_isEmpty = require 'lodash/isEmpty'
_map = require 'lodash/map'
_truncate = require 'lodash/truncate'
RxObservable = require('rxjs/Observable').Observable
require 'rxjs/add/operator/switchMap'
require 'rxjs/add/operator/map'

Base = require '../base'
Spinner = require '../spinner'
VideoListItem = require '../video_list_item'
colors = require '../../colors'

if window?
  require './index.styl'

MAX_TITLE_LENGTH = 60

module.exports = class GroupVideos extends Base
  constructor: ({@model, @router, group, sort, filter}) ->
    @$spinner = new Spinner()

    videos = group.switchMap (group) =>
      @model.video.getAllByGroupId(group.id, {sort, filter})

    @state = z.state
      $videos: videos.map (videos) =>
        _map videos, (video) =>
          @getCached$ video.id, VideoListItem, {
            @model, @router, video
          }

  afterMount: (@$$el) => null

  render: =>
    {me, $videos} = @state.getValue()

    z '.z-group-videos',
      z 'h2.title', @model.l.get 'videos.title'
      z '.g-grid',
        if $videos and _isEmpty $videos
          z '.no-videos',
            'No videos found'
        else if $videos
          z '.g-cols.no-padding',
          _map $videos, ($video) ->
            [
              z '.g-col.g-md-6.g-xs-12',
                z $video
            ]
        else
          @$spinner
