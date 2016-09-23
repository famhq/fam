z = require 'zorium'
_defaults = require 'lodash/object/defaults'
Button = require 'zorium-paper/button'
colors = require '../../colors'

module.exports = class SecondaryButton extends Button
  render: (opts) ->
    super _defaults opts, {
      isFullWidth: true
      isRaised: true
      isDark: true
      colors:
        cText: colors.$primary700
        c200: colors.$grey100
        c500: colors.$white
        c600: colors.$grey200
        c700: colors.$grey300
    }
