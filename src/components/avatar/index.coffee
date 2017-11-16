z = require 'zorium'
_find = require 'lodash/find'

if window?
  require './index.styl'

Icon = require '../icon'
config = require '../../config'
colors = require '../../colors'

DEFAULT_SIZE = '40px'

module.exports = class Avatar
  render: ({size, user, groupUser, src}) ->
    size ?= DEFAULT_SIZE
    src or= src or user?.avatarImage?.versions[0].url

    playerColors = config.PLAYER_COLORS
    lastChar = user?.id?.substr(user?.id?.length - 1, 1) or 'a'
    avatarColor = playerColors[ \
      Math.ceil (parseInt(lastChar, 16) / 16) * (playerColors.length - 1)
    ]

    # TODO: move to constructor so we don't do this loop every render
    if groupUser
      level = _find(config.XP_LEVEL_REQUIREMENTS, ({xpRequired}) ->
        groupUser.xp >= xpRequired
      )?.level

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
      if level
        z '.level',  {
          style:
            backgroundColor: config.XP_LEVEL_COLORS[level]
        },
          level
