z = require 'zorium'
isUuid = require 'isuuid'

GroupSendNotification = require '../../components/group_send_notification'
AppBar = require '../../components/app_bar'
ButtonMenu = require '../../components/button_menu'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class GroupSendNotificationPage
  isGroup: true

  constructor: ({@model, requests, @router, serverData, group}) ->
    @$appBar = new AppBar {@model}
    @$buttonMenu = new ButtonMenu {@model, @router}
    @$groupSendNotification = new GroupSendNotification {
      @model, @router, serverData, group
    }

    @state = z.state
      windowSize: @model.window.getSize()

  getMeta: =>
    {
      title: @model.l.get 'groupSendNotificationPage.title'
      description: @model.l.get 'groupSendNotificationPage.title'
    }

  render: =>
    {windowSize} = @state.getValue()

    z '.p-group-send-notification', {
      style:
        height: "#{windowSize.height}px"
    },
      z @$appBar, {
        title: @model.l.get 'groupSendNotificationPage.title'
        $topLeftButton: z @$buttonMenu, {
          color: colors.$header500Icon
        }
      }
      @$groupSendNotification
