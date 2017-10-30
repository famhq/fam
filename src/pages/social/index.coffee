z = require 'zorium'
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject

Head = require '../../components/head'
AppBar = require '../../components/app_bar'
ButtonMenu = require '../../components/button_menu'
BottomBar = require '../../components/bottom_bar'
FilterThreadsDialog = require '../../components/filter_threads_dialog'
Icon = require '../../components/icon'
Social = require '../../components/social'
colors = require '../../colors'

if window?
  require './index.styl'

TABS = ['groups', 'conversations']

module.exports = class SocialPage
  constructor: ({@model, requests, @router, serverData}) ->
    gameKey = requests.map ({route}) ->
      route?.params.gameKey or config.DEFAULT_GAME_KEY

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

    @$head = new Head({
      @model
      requests
      serverData
      meta: {
        title: @model.l.get 'general.social'
        description: @model.l.get 'general.social'
      }
    })

    @$appBar = new AppBar {@model}
    @$buttonMenu = new ButtonMenu {@model}
    @$social = new Social {
      @model
      @router
      pageTitle
      selectedIndex
      threadsFilter
      @isFilterThreadsDialogVisible
      gameKey
    }
    @$filterThreadsDialog = new FilterThreadsDialog {
      @model, filter: threadsFilter, isVisible: @isFilterThreadsDialogVisible
    }
    @$bottomBar = new BottomBar {@model, @router, requests}
    @$filterIcon = new Icon()

    @state = z.state
      windowSize: @model.window.getSize()
      isFilterThreadsDialogVisible: @isFilterThreadsDialogVisible
      pageTitle: pageTitle
      tabHack: tabHack
      language: @model.l.getLanguage()
      selectedIndex: selectedIndex

  renderHead: => @$head

  render: =>
    {windowSize, pageTitle, isFilterThreadsDialogVisible, language,
      selectedIndex} = @state.getValue()

    z '.p-social', {
      style:
        height: "#{windowSize.height}px"
    },
      z @$appBar, {
        title: pageTitle
        isFlat: true
        $topLeftButton:
          z @$buttonMenu, {color: colors.$primary500}
      }
      @$social
      @$bottomBar
      if isFilterThreadsDialogVisible
        z @$filterThreadsDialog
