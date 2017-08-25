z = require 'zorium'
Rx = require 'rx-lite'

Groups = require '../../components/groups'
Conversations = require '../../components/conversations'
Threads = require '../../components/threads'
Tabs = require '../../components/tabs'
Icon = require '../../components/icon'
Fab = require '../../components/fab'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class Social
  constructor: ({@model, @router, pageTitle, selectedIndex}) ->

    @$groups = new Groups {@model, @router}
    @$conversations = new Conversations {@model, @router}
    @$threads = new Threads {@model, @router}
    @$recruiting = new Threads {@model, @router, category: 'clan'}
    @$tabs = new Tabs {@model, selectedIndex}
    @$groupsIcon = new Icon()
    @$feedIcon = new Icon()
    @$recruitingIcon = new Icon()
    @$conversationsIcon = new Icon()
    @$addIcon = new Icon()
    @$fab = new Fab()

    @tabs = [
      {
        $menuIcon: @$groupsIcon
        menuIconName: 'chat'
        $menuText: @model.l.get 'communityPage.menuText'
        $el: @$groups
      }
      {
        $menuIcon: @$feedIcon
        menuIconName: 'rss'
        $menuText: @model.l.get 'communityPage.menuNews'
        $el: @$threads
      }
      {
        $menuIcon: @$recruitingIcon
        menuIconName: 'recruit'
        $menuText: @model.l.get 'general.recruiting'
        $el: @$recruiting
      }
      {
        $menuIcon: @$conversationsIcon
        menuIconName: 'inbox'
        $menuText: @model.l.get 'drawer.menuItemConversations'
        $el: @$conversations
      }
    ]

    @state = z.state
      selectedIndex: selectedIndex.map (index) =>
        # side effect
        pageTitle.onNext @tabs[index].$menuText
        index
      language: @model.l.getLanguage()

  render: =>
    {selectedIndex, language} = @state.getValue()

    z '.z-social',
      z @$tabs,
        isBarFixed: false
        tabs: @tabs
      if selectedIndex is 2 or (selectedIndex is 1 and language is 'es')
        z '.fab',
          z @$fab,
            colors:
              c500: colors.$primary500
            $icon: z @$addIcon, {
              icon: 'add'
              isTouchTarget: false
              color: colors.$white
            }
            onclick: =>
              if selectedIndex is 1
                @router.go '/new-thread'
              else
                @router.go '/new-thread/clan'
