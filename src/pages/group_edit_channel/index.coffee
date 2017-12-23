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

  constructor: ({@model, requests, @router, serverData}) ->
    group = requests.switchMap ({route}) =>
      if isUuid route.params.id
        @model.group.getById route.params.id
      else
        @model.group.getByKey route.params.id

    gameKey = requests.map ({route}) ->
      route.params.gameKey or config.DEFAULT_GAME_KEY

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
      @model, @router, serverData, group, conversation, gameKey
    }
    @$groupEditChannelPermissions = new GroupEditChannelPermissions {
      @model, @router, serverData, group, conversation, gameKey
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
