z = require 'zorium'

Sheet = require '../sheet'
PushService = require '../../services/push'

module.exports = class PushNotificationsSheet
  constructor: ({@model, router}) ->
    @$sheet = new Sheet {
      @model, router, isVisible: @model.pushNotificationSheet.isOpen()
    }

  render: =>
    z '.z-push-notifications-sheet',
      z @$sheet, {
        message: 'Turn on notifications so you don’t miss any
                  events or messages'
        icon: 'notifications'
        submitButton:
          text: 'Turn on'
          onclick: =>
            PushService.register {@model}
            @model.pushNotificationSheet.close()
      }
