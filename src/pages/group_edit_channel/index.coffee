z = require 'zorium'
isUuid = require 'isuuid'

Head = require '../../components/head'
AppBar = require '../../components/app_bar'
ButtonBack = require '../../components/button_back'
Tabs = require '../../components/tabs'
GroupEditChannel = require '../../components/group_edit_channel'
GroupEditChannelPermissions =
  require '../../components/group_edit_channel_permissions'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class GroupEditChannelPage
  isGroup: true

  constructor: ({@model, requests, @router, serverData, group}) ->
    conversation = requests.switchMap ({route}) =>
      @model.conversation.getById route.params.conversationId

    @$head = new Head({
      @model
      requests
      serverData
      meta: {
        title: @model.l.get 'groupEditChannelPage.title'
        description: @model.l.get 'groupEditChannelPage.title'
      }
    })
    @$appBar = new AppBar {@model}
    @$buttonBack = new ButtonBack {@model, @router}
    @$groupEditChannel = new GroupEditChannel {
      @model, @router, serverData, group, conversation
    }
    @$groupEditChannelPermissions = new GroupEditChannelPermissions {
      @model, @router, serverData, group, conversation
    }
    @$tabs = new Tabs {@model}

    @state = z.state
      group: group
      windowSize: @model.window.getSize()

  renderHead: => @$head

  render: =>
    {group, windowSize} = @state.getValue()

    z '.p-group-edit-channel', {
      style:
        height: "#{windowSize.height}px"
    },
      z @$appBar, {
        title: @model.l.get 'groupEditChannelPage.title'
        style: 'primary'
        isFlat: true
        $topLeftButton: z @$buttonBack, {color: colors.$primary500}
      }
      z @$tabs,
        isBarFixed: false
        hasAppBar: true
        tabs: [
          {
            $menuText: @model.l.get 'general.info'
            $el: @$groupEditChannel
          }
          {
            $menuText: @model.l.get 'general.permissions'
            $el: z @$groupEditChannelPermissions
          }
        ]
