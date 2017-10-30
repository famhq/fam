z = require 'zorium'
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject
require 'rxjs/add/operator/map'

AppBar = require '../../components/app_bar'
ButtonMenu = require '../../components/button_menu'
BottomBar = require '../../components/bottom_bar'
Tabs = require '../../components/tabs'
Icon = require '../../components/icon'
PlayersTop = require '../../components/players_top'
PlayersFollowing = require '../../components/players_following'
ProfileDialog = require '../../components/profile_dialog'
Head = require '../../components/head'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class PlayersPage
  constructor: ({@model, requests, router, serverData}) ->
    me = @model.user.getMe()
    selectedProfileDialogUser = new RxBehaviorSubject null
    overlay$ = new RxBehaviorSubject null

    gameKey = requests.map ({route}) ->
      route.params.gameKey or config.DEFAULT_GAME_KEY

    @$head = new Head({
      @model
      requests
      serverData
      meta: {
        title: @model.l.get 'playersPage.playersTop'
        description: @model.l.get 'playersPage.playersTop'
      }
    })
    @$appBar = new AppBar {@model}
    @$buttonMenu = new ButtonMenu {router, @model}
    @$bottomBar = new BottomBar {@model, router, requests}

    @$tabs = new Tabs {@model}
    @$profileDialog = new ProfileDialog {
      @model
      router
      selectedProfileDialogUser
      gameKey
    }

    @$playersTop = new PlayersTop {
      @model, router, selectedProfileDialogUser, gameKey
    }
    @$playersFollowing = new PlayersFollowing {
      @model, router, selectedProfileDialogUser, gameKey
    }

    @$followingIcon = new Icon()
    @$topPlayersIcon = new Icon()

    @state = z.state
      me: me
      windowSize: @model.window.getSize()
      overlay$: overlay$

  renderHead: => @$head

  render: =>
    {me, selectedProfileDialogUser, windowSize, overlay$} = @state.getValue()

    z '.p-players', {
      style:
        height: "#{windowSize.height}px"
    },
      z @$appBar,
        isFlat: true
        $topLeftButton: z @$buttonMenu, {color: colors.$primary500}
        title: @model.l.get 'playersPage.title'
      z @$tabs,
        isBarFixed: false
        tabs: [
          {
            $menuText: @model.l.get 'playersPage.playersTop'
            $el: @$playersTop
            $menuIcon: @$topPlayersIcon
            menuIconName: 'star'
          }
          {
            $menuText: @model.l.get 'playersPage.playersFollowing'
            $el: @$playersFollowing
            $menuIcon: @$followingIcon
            menuIconName: 'friends'
          }
        ]

      @$bottomBar

      if selectedProfileDialogUser
        @$profileDialog

      if overlay$
        overlay$
