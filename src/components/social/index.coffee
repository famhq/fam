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
    @$tabs = new Tabs {@model, selectedIndex}
    @$groupsIcon = new Icon()
    @$feedIcon = new Icon()
    @$conversationsIcon = new Icon()
    @$addIcon = new Icon()
    @$fab = new Fab()

    language = @model.l.getLanguage()

    tabs = language.map (lang) =>
      tabs = [
        {
          $menuIcon: @$groupsIcon
          menuIconName: 'chat'
          $menuText: @model.l.get 'communityPage.menuText'
          $el: @$groups
        }
        {
          $menuIcon: @$conversationsIcon
          menuIconName: 'inbox'
          $menuText: @model.l.get 'drawer.menuItemConversations'
          $el: @$conversations
        }
      ]
      pos = if lang is 'es' then 0 else 1
      tabs.splice pos, 0, {
        $menuIcon: @$feedIcon
        menuIconName: 'rss'
        $menuText: @model.l.get 'communityPage.menuNews'
        $el: @$threads
      }
      tabs

    selectedIndexAndTabs = Rx.Observable.combineLatest(
      selectedIndex, tabs, (vals...) -> vals
    )

    @state = z.state
      selectedIndex: selectedIndexAndTabs.map ([index, tabs]) ->
        # side effect
        pageTitle.onNext tabs[index].$menuText
        index
      tabs: tabs
      language: language

  render: =>
    {selectedIndex, language, tabs} = @state.getValue()

    z '.z-social',
      z @$tabs,
        isBarFixed: false
        tabs: tabs
      if selectedIndex is 2 or (selectedIndex is 0 and language is 'es')
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
              if selectedIndex is 0
                @router.go '/new-thread'
              else
                @router.go '/new-thread/clan'
