z = require 'zorium'

config = require '../../config'

if window?
  require './index.styl'

module.exports = class UserHeader
  render: ({user, src} = {}) ->
    src or= src or user?.avatarImage?.versions[0].url

    playerColors = config.PLAYER_COLORS
    lastChar = user?.id?.substr(user?.id?.length - 1, 1) or 'a'
    avatarColor = playerColors[ \
      Math.ceil (parseInt(lastChar, 16) / 16) * (playerColors.length - 1)
    ]

    z '.z-user-header', {
      style:
        backgroundImage: if src \
          then "url(#{src})"
          else 'none'
        backgroundColor: avatarColor
    }
