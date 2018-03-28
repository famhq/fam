z = require 'zorium'

AppBar = require '../../components/app_bar'
ButtonMenu = require '../../components/button_menu'
Groups = require '../../components/groups'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class GroupsPage
  constructor: ({@model, requests, @router, serverData, group}) ->
    @$appBar = new AppBar {@model}
    @$buttonMenu = new ButtonMenu {@model, @router}
    @$groups = new Groups {@model, @router}

    @state = z.state
      windowSize: @model.window.getSize()

  getMeta: =>
    {
      title: @model.l.get 'communityPage.menuText'
    }

  render: =>
    {windowSize} = @state.getValue()

    z '.p-groups', {
      style:
        height: "#{windowSize.height}px"
    },
      z @$appBar,
        $topLeftButton: z @$buttonMenu, {color: colors.$header500Icon}
        title: @model.l.get 'communityPage.menuText'
      @$groups
