z = require 'zorium'
_defaults = require 'lodash/object/defaults'
Button = require 'zorium-paper/button'
colors = require '../../colors'

module.exports = class PrimaryButton extends Button
  render: (opts) ->
    super _defaults opts, {
      isFullWidth: true
      isRaised: true
      isDark: true
      colors:
        c200: colors.$primary500
        c500: colors.$primary500
        c600: colors.$primary400
        c700: colors.$primary400
        ink: colors.$primaryInk
    }
