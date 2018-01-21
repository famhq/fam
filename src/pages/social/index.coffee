z = require 'zorium'
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject

AppBar = require '../../components/app_bar'
ButtonMenu = require '../../components/button_menu'
FilterThreadsDialog = require '../../components/filter_threads_dialog'
Icon = require '../../components/icon'
Social = require '../../components/social'
colors = require '../../colors'

if window?
  require './index.styl'

TABS = ['groups', 'conversations']

module.exports = class SocialPage
  constructor: ({@model, requests, @router, serverData, group}) ->
    pageTitle = new RxBehaviorSubject @model.l.get 'communityPage.menuText'
    selectedIndex = new RxBehaviorSubject 0
    @isFilterThreadsDialogVisible = new RxBehaviorSubject false
    threadsFilter = new RxBehaviorSubject {
      sort: 'popular'
      filter: 'all'
    }

    # hacky way to get /threads to go to 2nd tab
    tabHack = requests.map ({route}) ->
      if route.params.tab is 'threads'
        selectedIndex.next 0

    @$appBar = new AppBar {@model}
    @$buttonMenu = new ButtonMenu {@model}
    @$social = new Social {
      @model
      @router
      pageTitle
      selectedIndex
      threadsFilter
      @isFilterThreadsDialogVisible
      group
    }
    @$filterThreadsDialog = new FilterThreadsDialog {
      @model, filter: threadsFilter, isVisible: @isFilterThreadsDialogVisible
    }
    @$filterIcon = new Icon()

    @state = z.state
      windowSize: @model.window.getSize()
      isFilterThreadsDialogVisible: @isFilterThreadsDialogVisible
      pageTitle: pageTitle
      tabHack: tabHack
      language: @model.l.getLanguage()
      selectedIndex: selectedIndex

  getMeta: =>
    {
      title: @model.l.get 'general.social'
      description: @model.l.get 'general.social'
    }

  render: =>
    {windowSize, pageTitle, isFilterThreadsDialogVisible, language,
      selectedIndex} = @state.getValue()

    z '.p-social', {
      style:
        height: "#{windowSize.height}px"
    },
      z @$appBar, {
        title: pageTitle
        $topLeftButton:
          z @$buttonMenu, {color: colors.$header500Icon}
      }
      @$social
      if isFilterThreadsDialogVisible
        z @$filterThreadsDialog
