z = require 'zorium'
Rx = require 'rx-lite'

Dialog = require '../dialog'
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class GetAppDialog
  constructor: ({@model}) ->
    @$dialog = new Dialog()

  render: =>
    z '.z-get-app-dialog',
      z @$dialog,
        isVanilla: true
        onLeave: =>
          @model.getAppDialog.close()
        $content:
          z '.z-get-app-dialog_dialog',
            z '.badge.ios', {
              onclick: =>
                @model.portal.call 'browser.openWindow',
                  url: config.IOS_APP_URL
                  target: '_system'
            }
            z '.badge.android', {
              onclick: =>
                @model.portal.call 'browser.openWindow',
                  url: config.GOOGLE_PLAY_APP_URL
                  target: '_system'
            }
            z '.text',
              'Take your stats on the go with the Starfire app
              for Android and iOS!'
        cancelButton:
          text: 'cancel'
          onclick: =>
            @model.getAppDialog.close()
