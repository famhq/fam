z = require 'zorium'
_defaultsDeep = require 'lodash/defaultsDeep'

Button = require '../button'
colors = require '../../colors'

module.exports = class FlatButton extends Button
  render: (opts) ->
    super _defaultsDeep opts, {
      isFullWidth: true
      colors:
        cText: colors.$white
        # c200: colors.$grey100
        # c500: colors.$white
        # c600: colors.$grey200
        # c700: colors.$grey300
    }
