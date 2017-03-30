z = require 'zorium'
Rx = require 'rx-lite'

AppBar = require '../../components/app_bar'
ButtonMenu = require '../../components/button_menu'
Tabs = require '../../components/tabs'
Icon = require '../../components/icon'
PlayersTop = require '../../components/players_top'
PlayersFollowing = require '../../components/players_following'
ProfileDialog = require '../../components/profile_dialog'
Head = require '../../components/head'

if window?
  require './index.styl'

module.exports = class PlayersPage
  constructor: ({model, requests, router, serverData}) ->
    me = model.user.getMe()
    selectedProfileDialogUser = new Rx.BehaviorSubject null

    @$head = new Head({
      model
      requests
      serverData
      meta: {
        title: 'Players'
        description: 'Players'
      }
    })
    @$appBar = new AppBar {model}
    @$buttonMenu = new ButtonMenu {router, model}

    @$tabs = new Tabs {model}
    @$profileDialog = new ProfileDialog {
      model
      router
      selectedProfileDialogUser: selectedProfileDialogUser
    }

    @$playersTop = new PlayersTop {
      model, router, selectedProfileDialogUser
    }
    @$playersFollowing = new PlayersFollowing {
      model, router, selectedProfileDialogUser
    }

    @state = z.state
      me: me
      windowSize: model.window.getSize()

  renderHead: => @$head

  render: =>
    {me, selectedProfileDialogUser, windowSize} = @state.getValue()

    z '.p-players', {
      style:
        height: "#{windowSize.height}px"
    },
      z @$appBar,
        isFlat: true
        $topLeftButton: @$buttonMenu
        title: 'Players'
      z @$tabs,
        isBarFixed: false
        tabs: [
          {
            $menuText: 'Top players'
            $el: @$playersTop
          }
          {
            $menuText: 'Following'
            $el: @$playersFollowing
          }
        ]

      if selectedProfileDialogUser
        @$profileDialog
