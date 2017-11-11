z = require 'zorium'
_isEmpty = require 'lodash/isEmpty'
_map = require 'lodash/map'
_truncate = require 'lodash/truncate'
moment = require 'moment'
require 'moment-duration-format'
RxObservable = require('rxjs/Observable').Observable
require 'rxjs/add/operator/switchMap'
require 'rxjs/add/operator/map'

Base = require '../base'
Icon = require '../icon'
Card = require '../card'
Spinner = require '../spinner'
FormatService = require '../../services/format'
colors = require '../../colors'

if window?
  require './index.styl'

MAX_TITLE_LENGTH = 60

module.exports = class GroupVideos
  constructor: ({@model, @router, group, sort, filter}) ->
    @$spinner = new Spinner()

    me = @model.user.getMe()
    videos = group.switchMap (group) =>
      @model.video.getAllByGroupId(group.id, {sort, filter})

    @state = z.state
      me: @model.user.getMe()
      videos: videos.map (videos) ->
        console.log 'videos...', videos
        _map videos, (video) ->
          {
            video
            $sourceIcon: new Icon()
          }

  render: =>
    {me, videos} = @state.getValue()

    z '.z-videos',
      z 'h2.title', @model.l.get 'videos.title'
      z '.videos',
        if videos and _isEmpty videos
          'No videos found'
        else if videos
          _map videos, ({video, $sourceIcon}) =>
            [
              z 'a.video', {
                href: "https://www.youtube.com/watch?v=#{video.sourceId}"
                onclick: (e) =>
                  e?.preventDefault()
                  ga? 'send', 'event', 'video', 'click', video.sourceId
                  @model.portal.call 'browser.openWindow', {
                    url: "https://www.youtube.com/watch?v=#{video.sourceId}"
                    target: '_system'
                  }
              },
                z '.thumbnail', {
                  style:
                    backgroundImage:
                      "url(#{video.thumbnailImage?.versions[0].url})"
                },
                  z '.bottom-right',
                    z '.duration', moment.duration(video.duration).format()
                    z '.source-icon',
                      z $sourceIcon,
                        icon: video.source
                        isTouchTarget: false
                        color: colors.$white
                        size: '14px'
                z '.info',
                  z '.title', _truncate video.title, {length: MAX_TITLE_LENGTH}
                  z '.author', video.authorName
              z '.divider'
            ]
        else
          @$spinner
