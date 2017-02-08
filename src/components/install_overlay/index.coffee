z = require 'zorium'

Icon = require '../icon'
PrimaryButton = require '../primary_button'
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class InstallOverlay
  constructor: ({@model, @router}) ->
    @$overflowIcon = new Icon()
    @$closeButton = new PrimaryButton()

  afterMount: =>
    @router.onBack =>
      @model.installOverlay.close()

  beforeUnmount: =>
    @router.onBack null

  render: =>
    z '.z-install-overlay',
      z '.container',
        z '.content',
          z '.title', 'Add Starfi.re to homescreen'
          z '.action',
            z '.text', 'Tap'
            z '.icon',
              z @$overflowIcon,
                icon: 'overflow'
                color: colors.$white
                isTouchTarget: false
          z '.instructions',
            'Select \'Add to homescreen\' to pin the Starfi.re web app'
          z '.button',
            z @$closeButton, {
              text: 'Got it'
              isFullWidth: false
              colors:
                cText: colors.$tertiary700Text
                c200: colors.$tertiary400
                c500: colors.$tertiary500
                c600: colors.$tertiary600
                c700: colors.$tertiary700
              onclick: =>
                @model.installOverlay.close()
          }
        z '.arrow'
