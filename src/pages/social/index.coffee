z = require 'zorium'
Rx = require 'rx-lite'

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
    pageTitle = new Rx.BehaviorSubject @model.l.get 'communityPage.menuText'
    selectedIndex = new Rx.BehaviorSubject 0
    @isFilterThreadsDialogVisible = new Rx.BehaviorSubject false
    threadsFilter = new Rx.BehaviorSubject {
      sort: 'popular'
      filter: 'all'
    }

    # hacky way to get /threads to go to 2nd tab
    tabHack = requests.map ({route}) ->
      if route.params.tab is 'threads'
        selectedIndex.onNext 0

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
        $topRightButton:
          if language is 'es' and selectedIndex is 0 and @model.experiment.get('forum') isnt 'visible'
            z @$filterIcon,
              color: colors.$primary500
              icon: 'filter'
              onclick: =>
                @isFilterThreadsDialogVisible.onNext true
      }
      @$social
      @$bottomBar
      if isFilterThreadsDialogVisible
        z @$filterThreadsDialog
