z = require 'zorium'

PrimaryButton = require '../primary_button'

if window?
  require './index.styl'

module.exports = class OfflineOverlay
  constructor: ({@isOffline}) ->
    @$closeButton = new PrimaryButton()

  render: =>
    z '.z-offline-overlay',
      'Looks like you\'re offline. Reconnect to the internet to resume'
      z '.close-button',
        z @$closeButton,
          text: 'Close this message'
          isFullWidth: false
          onclick: =>
            @isOffline.onNext false
