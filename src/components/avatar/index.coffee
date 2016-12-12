z = require 'zorium'

if window?
  require './index.styl'

Icon = require '../icon'
config = require '../../config'

DEFAULT_SIZE = '40px'

module.exports = class Avatar
  render: ({size, user, src}) ->
    size ?= DEFAULT_SIZE
    src or= src or user?.avatarImage?.versions[0].url

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
      if src
        z '.image',
          style:
            backgroundImage: "url(#{src})"
