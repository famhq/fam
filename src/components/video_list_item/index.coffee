z = require 'zorium'
_truncate = require 'lodash/truncate'

Icon = require '../icon'
DateService = require '../../services/date'
colors = require '../../colors'

if window?
  require './index.styl'

MAX_TITLE_LENGTH = 60

module.exports = class VideoListItem
  constructor: ({@model, @router, video}) ->
    @$sourceIcon = new Icon()

    @state = z.state
      video: video

  render: ({hasPadding} = {}) =>
    hasPadding ?= true

    {video} = @state.getValue()

    z 'a.z-video-list-item', {
      className: z.classKebab {hasPadding}
      href: "https://www.youtube.com/watch?v=#{video.sourceId}"
      onclick: (e) =>
        e?.preventDefault()
        ga? 'send', 'event', 'video', 'click', video.sourceId
        x = e?.clientX
        y = e?.clientY
        @model.video.logViewById video.id
        .then (response) =>
          if response?.xpGained
            @model.xpGain.show {xp: response.xpGained, x, y}
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
          z '.duration', DateService.formatDuration video.duration
          z '.source-icon',
            z @$sourceIcon,
              icon: video.source
              isTouchTarget: false
              color: colors.$tertiary900Text
              size: '14px'
      z '.info',
        z '.title', _truncate video.title, {length: MAX_TITLE_LENGTH}
        z '.author', video.authorName
