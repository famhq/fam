z = require 'zorium'
colors = require '../../colors'

if window?
  require './index.styl'

Icon = require '../icon'
config = require '../../config'

SMALL_WIDTH = 128
SMALL_HEIGHT = 128

module.exports = class Avatar
  render: ({size, user, src}) ->
    size ?= '40px'
    avatarUrl = src or user?.avatarImage?.versions[0].url

    playerColors = config.PLAYER_COLORS
    lastChar = user?.id?.substr(user?.id?.length - 1, 1) or 'a'
    avatarColor = playerColors[ \
      Math.ceil (parseInt(lastChar, 16) / 16) * (playerColors.length - 1)
    ]

    z '.z-avatar', {
      style:
        width: size
        height: size
        backgroundColor: avatarColor
    },
      if avatarUrl
        z '.image',
          style:
            backgroundImage: "url(#{avatarUrl})"
