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
  constructor: ({@model, @router}) ->
    selectedIndex = new Rx.BehaviorSubject 0

    @$groups = new Groups {@model, @router}
    @$conversations = new Conversations {@model, @router}
    @$threads = new Threads {@model, @router}
    @$tabs = new Tabs {@model, selectedIndex}
    @$groupsIcon = new Icon()
    @$feedIcon = new Icon()
    @$conversationsIcon = new Icon()
    @$addIcon = new Icon()
    @$fab = new Fab()

    @state = z.state
      selectedIndex: selectedIndex
      language: @model.l.getLanguage()

  render: =>
    {selectedIndex, language} = @state.getValue()

    z '.z-social',
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
            $menuIcon: @$feedIcon
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
      if selectedIndex is 1 and language is 'es'
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
              @router.go '/newThread'
