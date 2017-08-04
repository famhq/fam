z = require 'zorium'

if window?
  require './index.styl'

config = require '../../config'
colors = require '../../colors'

DEFAULT_WIDTH = 80
DEFAULT_HEIGHT = 96

module.exports = class Card
  constructor: ({card}) ->
    @state = z.state {card}

  render: ({width, onclick} = {}) =>
    {card} = @state.getValue()

    width ?= DEFAULT_WIDTH
    height = width * (DEFAULT_HEIGHT / DEFAULT_WIDTH)
    cdnUrl = config.CDN_URL

    z '.z-card', {
      onclick: ->
        onclick? card
      key: card?.id
      style:
        width: "#{width}px"
        height: "#{height}px"
        backgroundImage: if card and card.key \
                         then "url(#{cdnUrl}/cards/#{card.key}_small.png?1)"
                         else null
        backgroundColor: if card and card.key then null else colors.$black

    }
