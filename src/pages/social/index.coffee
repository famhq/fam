z = require 'zorium'
Rx = require 'rx-lite'

Head = require '../../components/head'
AppBar = require '../../components/app_bar'
ButtonMenu = require '../../components/button_menu'
BottomBar = require '../../components/bottom_bar'
Social = require '../../components/social'
colors = require '../../colors'

if window?
  require './index.styl'

TABS = ['groups', 'conversations']

module.exports = class SocialPage
  constructor: ({@model, requests, @router, serverData}) ->
    pageTitle = new Rx.BehaviorSubject @model.l.get 'communityPage.menuText'
    selectedIndex = new Rx.BehaviorSubject 0

    # hacky way to get /threads to go to 2nd tab
    tabHack = requests.map ({route}) ->
      if route.params.tab is 'threads'
        selectedIndex.onNext 1

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
    @$social = new Social {@model, @router, pageTitle, selectedIndex}
    @$bottomBar = new BottomBar {@model, @router, requests}

    @state = z.state
      windowSize: @model.window.getSize()
      pageTitle: pageTitle
      tabHack: tabHack

  renderHead: => @$head

  render: =>
    {windowSize, pageTitle} = @state.getValue()

    z '.p-social', {
      style:
        height: "#{windowSize.height}px"
    },
      z @$appBar, {
        title: pageTitle
        isFlat: true
        $topLeftButton: z @$buttonMenu, {color: colors.$primary500}
      }
      @$social
      @$bottomBar
