z = require 'zorium'
RxObservable = require('rxjs/Observable').Observable
require 'rxjs/add/operator/map'
require 'rxjs/add/observable/combineLatest'

Groups = require '../../components/groups'
Conversations = require '../../components/conversations'
Tabs = require '../../components/tabs'
Icon = require '../../components/icon'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class Social
  constructor: ({@model, @router, pageTitle, selectedIndex}) ->
    @$groups = new Groups {@model, @router}
    @$conversations = new Conversations {@model, @router}
    @$tabs = new Tabs {@model, selectedIndex}
    @$groupsIcon = new Icon()
    @$feedIcon = new Icon()
    @$conversationsIcon = new Icon()

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

    selectedIndexAndTabs = RxObservable.combineLatest(
      selectedIndex, tabs, (vals...) -> vals
    )

    @state = z.state
      selectedIndex: selectedIndexAndTabs.map ([index, tabs]) ->
        # side effect
        pageTitle.next tabs[index].$menuText
        index
      tabs: tabs
      language: language

  render: =>
    {selectedIndex, language, tabs} = @state.getValue()

    z '.z-social',
      z @$tabs,
        isBarFixed: false
        tabs: tabs
