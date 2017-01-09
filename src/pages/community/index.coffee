z = require 'zorium'
Rx = require 'rx-lite'
FloatingActionButton = require 'zorium-paper/floating_action_button'

Head = require '../../components/head'
AppBar = require '../../components/app_bar'
ButtonMenu = require '../../components/button_menu'
Threads = require '../../components/threads'
Groups = require '../../components/groups'
Conversations = require '../../components/conversations'
Tabs = require '../../components/tabs'
Icon = require '../../components/icon'
colors = require '../../colors'

if window?
  require './index.styl'

TABS = ['groups', 'conversations']

module.exports = class CommunityPage
  constructor: ({@model, requests, @router, serverData}) ->
    @$head = new Head({
      @model
      requests
      serverData
      meta: {
        title: 'Community'
        description: 'Community'
      }
    })

    selectedIndex = new Rx.BehaviorSubject 0

    @$appBar = new AppBar {@model}
    @$buttonMenu = new ButtonMenu {@model}
    @$threads = new Threads {@model, @router}
    @$groups = new Groups {@model, @router}
    @$conversations = new Conversations {@model, @router}
    @$tabs = new Tabs {@model, selectedIndex}
    @$threadsIcon = new Icon()
    @$groupsIcon = new Icon()
    @$conversationsIcon = new Icon()
    @$fab = new FloatingActionButton()
    @$plusIcon = new Icon()

    @state = z.state
      selectedIndex: selectedIndex
      windowSize: @model.window.getSize()

  renderHead: => @$head

  render: =>
    {selectedIndex, windowSize} = @state.getValue()

    z '.p-community', {
      style:
        height: "#{windowSize.height}px"
    },
      z @$appBar, {
        title: 'Community'
        isFlat: true
        $topLeftButton: z @$buttonMenu, {color: colors.$tertiary900}
      }
      z @$tabs,
        isBarFixed: false
        tabs: [
          # {
          #   $menuIcon: @$threadsIcon
          #   menuIconName: 'chat'
          #   $menuText: 'Threads'
          #   $el: @$threads
          # }
          {
            $menuIcon: @$groupsIcon
            menuIconName: 'grid'
            $menuText: 'Groups'
            $el: @$groups
          }
          {
            $menuIcon: @$conversationsIcon
            menuIconName: 'inbox'
            $menuText: 'Conversations'
            $el: @$conversations
          }
        ]
      z '.fab',
        z @$fab,
          colors:
            c500: colors.$primary500
          $icon: z @$plusIcon, {
            icon: 'add'
            isTouchTarget: false
            color: colors.$white
          }
          onclick: =>
            tab = TABS[selectedIndex]
            if tab is 'groups'
              @router.go '/newGroup'
            else
              @router.go '/newConversation'
