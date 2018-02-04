z = require 'zorium'

if window?
  Scratchie = require '../../lib/scratchie.js'
  require './index.styl'

module.exports = class ScratchieWidget
  type: 'Widget'

  constructor: ({@model, @topImageSrc, @onStart}) -> null

  afterMount: ($$el) =>
    @topImageSrc.take(1).subscribe (topImageSrc) =>
      new Scratchie $$el, {
        image: topImageSrc
        onStart: @onStart
        onRenderEnd: ->
          null
        # onScratchMove: (filledInPixels) ->
        #   null
      }

  # beforeUnmount: =>
    # @chart?.detach()

  render: ({$content}) ->
    z '.z-scratchie-widget', {
      id: 'scratch'
      style:
        width: '100%'
        height: '100%'
    },
      z '.content',
        $content
