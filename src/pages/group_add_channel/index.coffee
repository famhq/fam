z = require 'zorium'
isUuid = require 'isuuid'

Head = require '../../components/head'
AppBar = require '../../components/app_bar'
ButtonBack = require '../../components/button_back'
GroupEditChannel = require '../../components/group_edit_channel'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class GroupAddChannelPage
  isGroup: true

  constructor: ({@model, requests, @router, serverData, group}) ->
    @$head = new Head({
      @model
      requests
      serverData
      meta: {
        title: @model.l.get 'groupAddChannelPage.title'
        description: @model.l.get 'groupAddChannelPage.title'
      }
    })
    @$appBar = new AppBar {@model}
    @$buttonBack = new ButtonBack {@model, @router}
    @$groupEditChannel = new GroupEditChannel {
      @model, @router, serverData, group
    }

    @state = z.state
      group: group
      windowSize: @model.window.getSize()

  renderHead: => @$head

  render: =>
    {group, windowSize} = @state.getValue()

    z '.p-group-add-channel', {
      style:
        height: "#{windowSize.height}px"
    },
      z @$appBar, {
        title: @model.l.get 'groupAddChannelPage.title'
        style: 'primary'
        isFlat: true
        $topLeftButton: z @$buttonBack, {color: colors.$primary500}
      }
      z @$groupEditChannel, {isNewChannel: true}
