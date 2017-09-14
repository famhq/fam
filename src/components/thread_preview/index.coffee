z = require 'zorium'
_find = require 'lodash/find'

if window?
  require './index.styl'

config = require '../../config'
colors = require '../../colors'

PADDING = 16

module.exports = class ThreadPreview
  constructor: ({@model, thread}) ->
    @state = z.state
      thread: thread
      windowSize: @model.window.getSize()

  render: ({width} = {}) =>
    {windowSize, thread} = @state.getValue()

    unless thread
      return

    imageAttachment = _find thread.attachments, {type: 'image'}
    videoAttachment = _find thread.attachments, {type: 'video'}
    width ?= windowSize.width - PADDING * 2

    z '.z-thread-preview',
      if videoAttachment and videoAttachment.mp4Src
        z 'video.video', {
          width: width
          attributes:
            loop: true
            controls: true
            autoplay: true
        },
          z 'source',
            type: 'video/mp4'
            src: videoAttachment.mp4Src
          z 'source',
            type: 'video/mp4'
            src: videoAttachment.webmSrc
      else if videoAttachment
        z 'iframe',
          width: width
          height: width * (9 / 16)
          src: videoAttachment.src
          attributes:
            frameborder: 0
            allowfullscreen: true
            webkitallowfullscreen: true
      else if imageAttachment
        z 'img.image', {
          src: imageAttachment.src
        }
