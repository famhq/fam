z = require 'zorium'
_defaults = require 'lodash/object/defaults'
Input = require 'zorium-paper/input'
colors = require '../../colors'

module.exports = class PrimaryInput extends Input
  render: (opts) ->
    super _defaults opts, {
      isFullWidth: true
      isRaised: true
      isDark: true
      colors:
        c200: colors.$tertiary200Text
        c500: colors.$tertiary500Text
        c600: colors.$tertiary600Text
        c700: colors.$tertiary700Text
        ink: colors.$tertiary700Text
    }
