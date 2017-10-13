z = require 'zorium'
_defaults = require 'lodash/defaults'

Button = require '../button'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class SecondaryButton extends Button
  render: (opts) ->
    z '.z-secondary-button',
      super _defaults opts, {
        isFullWidth: true
        colors:
          cText: colors.$primary500
      }
