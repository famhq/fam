z = require 'zorium'
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject
require 'rxjs/add/operator/map'

Tabs = require '../tabs'
Icon = require '../icon'
PlayersTop = require '../players_top'
PlayersFollowing = require '../players_following'
ProfileDialog = require '../profile_dialog'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class ClashRoyalePlayers
  constructor: ({@model, router, group}) ->
    me = @model.user.getMe()
    selectedProfileDialogUser = new RxBehaviorSubject null
    overlay$ = new RxBehaviorSubject null

    @$tabs = new Tabs {@model}
    @$profileDialog = new ProfileDialog {
      @model
      router
      selectedProfileDialogUser
      group
    }

    @$playersTop = new PlayersTop {
      @model, router, selectedProfileDialogUser
    }
    @$playersFollowing = new PlayersFollowing {
      @model, router, selectedProfileDialogUser
    }

    @$followingIcon = new Icon()
    @$topPlayersIcon = new Icon()

    @state = z.state
      me: me
      windowSize: @model.window.getSize()
      overlay$: overlay$

  render: =>
    {me, selectedProfileDialogUser, windowSize, overlay$} = @state.getValue()

    z '.z-players', {
      style:
        height: "#{windowSize.height}px"
    },
      z @$appBar,
        isFlat: true
        $topLeftButton: z @$buttonMenu, {color: colors.$header500Icon}
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

      if selectedProfileDialogUser
        @$profileDialog

      if overlay$
        overlay$
