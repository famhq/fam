z = require 'zorium'

Dialog = require '../dialog'
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class GetAppDialog
  constructor: ({@model, group}) ->
    @$dialog = new Dialog()

    @state = z.state
      group: group

  render: =>
    {group} = @state.getValue()

    iosAppId = group?.iosAppId or config.DEFAULT_IOS_APP_ID
    googlePlayAppId = group?.googlePlayAppId or
                        config.DEFAULT_GOOGLE_PLAY_APP_ID

    iosAppUrl = 'https://itunes.apple.com/us/app/fam/id' + iosAppId
    googlePlayAppUrl = 'https://play.google.com/store/apps/details?id=' +
      googlePlayAppId

    z '.z-get-app-dialog',
      z @$dialog,
        isVanilla: true
        onLeave: =>
          @model.getAppDialog.close()
        $title: group?.name
        $content:
          z '.z-get-app-dialog_dialog',
            z '.badge.ios', {
              onclick: =>
                @model.portal.call 'browser.openWindow',
                  url: iosAppUrl
                  target: '_system'
            }
            z '.badge.android', {
              onclick: =>
                @model.portal.call 'browser.openWindow',
                  url: googlePlayAppUrl
                  target: '_system'
            }
            # z '.text',
            #   @model.l.get 'getAppDialog.text'
        cancelButton:
          text: @model.l.get 'general.cancel'
          onclick: =>
            @model.getAppDialog.close()
