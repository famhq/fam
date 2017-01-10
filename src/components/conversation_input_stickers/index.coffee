z = require 'zorium'
_map = require 'lodash/map'

colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

DEFAULT_TEXTAREA_HEIGHT = 54
SEARCH_DEBOUNCE = 300

module.exports = class ConversationInputStickers
  constructor: ({@onPost, @message}) -> null

  getHeightPx: ->
    98

  render: =>
    z '.z-conversation-input-stickers',
      z '.stickers',
        _map config.STICKERS, (sticker) =>
          z '.sticker',
            onclick: (e) =>
              @message.onNext ":#{sticker}:"
              @onPost()
            style:
              backgroundImage:
                "url(#{config.CDN_URL}/groups/emotes/#{sticker}.png)"
