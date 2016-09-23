z = require 'zorium'
log = require 'loga'

config = require '../../config'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class AppBar
  constructor: ({@model}) -> null

  render: ({$topLeftButton, $topRightButton, title, bgColor, color, isFlat}) ->
    color ?= colors.$tertiary700Text
    bgColor ?= colors.$tertiary700
    z 'header.z-app-bar', {
      className: z.classKebab {isFlat}
    },
      z '.bar', {
        style:
          backgroundColor: bgColor
      },
        z '.g-grid',
          z '.top',
            if $topLeftButton
              z '.top-left-button', {
                style:
                  color: color
              },
                $topLeftButton
            z '.title', {
              style:
                color: color
            }, title
            z '.top-right-button', {
              style:
                color: color
            },
              $topRightButton
