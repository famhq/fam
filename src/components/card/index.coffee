z = require 'zorium'
colors = require '../../colors'

if window?
  require './index.styl'

config = require '../../config'

SMALL_WIDTH = 128
SMALL_HEIGHT = 128

module.exports = class Card
  constructor: ({card}) ->
    @state = z.state {card}

  render: ({width, onclick} = {}) =>
    {card} = @state.getValue()

    width ?= 76
    height = width * (96 / 76)

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
