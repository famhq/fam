z = require 'zorium'

Head = require '../../components/head'
AppBar = require '../../components/app_bar'
ButtonMenu = require '../../components/button_menu'
GroupAddons = require '../../components/group_addons'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class GroupAddonsPage
  isGroup: true
  @hasBottomBar: true

  constructor: ({@model, requests, @router, serverData, group, @$bottomBar}) ->
    @$head = new Head({
      @model
      requests
      serverData
      meta: {
        title: @model.l.get 'addonsPage.title'
        description: @model.l.get 'addonsPage.title'
      }
    })
    @$appBar = new AppBar {@model}
    @$buttonMenu = new ButtonMenu {@model}

    @$groupAddons = new GroupAddons {@model, @router, sort: 'popular', group}

    @state = z.state
      windowSize: @model.window.getSize()

  renderHead: => @$head

  render: =>
    {windowSize} = @state.getValue()

    z '.p-group-addons', {
      style:
        height: "#{windowSize.height}px"
    },
      z @$appBar, {
        title: @model.l.get 'addonsPage.title'
        isFlat: true
        $topLeftButton: z @$buttonMenu, {color: colors.$primary500}
      }
      @$groupAddons
      z @$bottomBar
