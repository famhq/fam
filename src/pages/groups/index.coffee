z = require 'zorium'

Head = require '../../components/head'
AppBar = require '../../components/app_bar'
ButtonMenu = require '../../components/button_menu'
Groups = require '../../components/groups'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class GroupsPage
  constructor: ({@model, requests, @router, serverData}) ->
    @$head = new Head({
      @model
      requests
      serverData
      meta: {
        title: @model.l.get 'drawer.menuItemGroups'
        description: @model.l.get 'drawer.menuItemGroups'
      }
    })
    @$appBar = new AppBar {@model}
    @$buttonMenu = new ButtonMenu {@model, @router}
    @$conversations = new Groups {@model, @router}

    @state = z.state
      windowSize: @model.window.getSize()

  renderHead: => @$head

  render: =>
    {windowSize} = @state.getValue()

    z '.p-groups', {
      style:
        height: "#{windowSize.height}px"
    },
      z @$appBar,
        isFlat: true
        $topLeftButton: z @$buttonMenu, {color: colors.$primary500}
        title: @model.l.get 'communityPage.menuText'
      @$conversations
