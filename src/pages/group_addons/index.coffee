z = require 'zorium'

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
    highlightedKey = requests.map ({route}) ->
      route.params.highlightedKey

    @$appBar = new AppBar {@model}
    @$buttonMenu = new ButtonMenu {@model}

    @$groupAddons = new GroupAddons {
      @model, @router, sort: 'popular', group, highlightedKey
    }

    @state = z.state
      windowSize: @model.window.getSize()

  getMeta: =>
    {
      title: @model.l.get 'addonsPage.title'
    }

  render: =>
    {windowSize} = @state.getValue()

    z '.p-group-addons', {
      style:
        height: "#{windowSize.height}px"
    },
      z @$appBar, {
        title: @model.l.get 'addonsPage.title'
        $topLeftButton: z @$buttonMenu, {color: colors.$header500Icon}
      }
      @$groupAddons
      z @$bottomBar
