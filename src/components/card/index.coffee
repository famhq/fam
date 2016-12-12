z = require 'zorium'

if window?
  require './index.styl'

config = require '../../config'
colors = require '../../colors'

DEFAULT_WIDTH = 76
DEFAULT_HEIGHT = 96

module.exports = class Card
  constructor: ({card}) ->
    @state = z.state {card}

  render: ({width, onclick} = {}) =>
    {card} = @state.getValue()

    width ?= DEFAULT_WIDTH
    height = width * (DEFAULT_HEIGHT / DEFAULT_WIDTH)

    z '.z-card', {
      onclick: ->
        onclick? card
      style:
        width: "#{width}px"
        height: "#{height}px"
        backgroundImage: if card and card.key \
                         then "url(#{config.CDN_URL}/cards/#{card.key}.png)"
                         else null
        backgroundColor: if card and card.key then null else colors.$tertiary900

    }
