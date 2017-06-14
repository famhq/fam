z = require 'zorium'
Rx = require 'rx-lite'

Head = require '../../components/head'
AppBar = require '../../components/app_bar'
ButtonMenu = require '../../components/button_menu'
BottomBar = require '../../components/bottom_bar'
Groups = require '../../components/groups'
Conversations = require '../../components/conversations'
Threads = require '../../components/threads'
Tabs = require '../../components/tabs'
Icon = require '../../components/icon'
Fab = require '../../components/fab'
colors = require '../../colors'

if window?
  require './index.styl'

TABS = ['groups', 'conversations']

module.exports = class SocialPage
  constructor: ({@model, requests, @router, serverData}) ->
    @$head = new Head({
      @model
      requests
      serverData
      meta: {
        title: @model.l.get 'general.social'
        description: @model.l.get 'general.social'
      }
    })

    selectedIndex = new Rx.BehaviorSubject 0

    @$appBar = new AppBar {@model}
    @$buttonMenu = new ButtonMenu {@model}
    @$groups = new Groups {@model, @router}
    @$conversations = new Conversations {@model, @router}
    @$threads = new Threads {@model, @router}
    @$tabs = new Tabs {@model, selectedIndex}
    @$groupsIcon = new Icon()
    @$conversationsIcon = new Icon()
    @$bottomBar = new BottomBar {@model, @router, requests}

    @state = z.state
      selectedIndex: selectedIndex
      windowSize: @model.window.getSize()

  renderHead: => @$head

  render: =>
    {selectedIndex, windowSize} = @state.getValue()

    z '.p-social', {
      style:
        height: "#{windowSize.height}px"
    },
      z @$appBar, {
        title: @model.l.get 'general.social'
        isFlat: true
        $topLeftButton: z @$buttonMenu, {color: colors.$primary500}
      }
      z @$tabs,
        isBarFixed: false
        tabs: [
          {
            $menuIcon: @$groupsIcon
            menuIconName: 'chat'
            $menuText: @model.l.get 'communityPage.menuText'
            $el: @$groups
          }
          {
            $menuIcon: @$groupsIcon
            menuIconName: 'rss'
            $menuText: @model.l.get 'communityPage.menuNews'
            $el: @$threads
          }
          {
            $menuIcon: @$conversationsIcon
            menuIconName: 'inbox'
            $menuText: @model.l.get 'drawer.menuItemConversations'
            $el: @$conversations
          }
        ]
      @$bottomBar
