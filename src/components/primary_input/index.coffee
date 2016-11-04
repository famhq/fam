z = require 'zorium'
_defaults = require 'lodash/object/defaults'
Input = require 'zorium-paper/input'

Icon = require '../icon'
colors = require '../../colors'


if window?
  require './index.styl'

module.exports = class PrimaryInput extends Input
  constructor: ->
    @state = z.state isPasswordVisible: false
    @$eyeIcon = new Icon()
    super

  render: (opts) =>
    {isPasswordVisible} = @state.getValue()

    optType = opts.type

    opts.type = if isPasswordVisible then 'text' else opts.type

    z '.z-primary-input',
      super _defaults opts, {
        isFullWidth: true
        isRaised: true
        isFloating: true
        isDark: true
        colors:
          c200: colors.$tertiary200Text
          c500: colors.$tertiary500Text
          c600: colors.$tertiary600Text
          c700: colors.$tertiary700Text
          ink: colors.$tertiary700Text
      }
      if optType is 'password'
        z '.make-visible', {
          onclick: =>
            @state.set isPasswordVisible: not isPasswordVisible
        },
          z @$eyeIcon,
            icon: 'eye'
            color: colors.$white
