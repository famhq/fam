z = require 'zorium'
Rx = require 'rxjs'

Head = require '../../components/head'
Tabs = require '../../components/tabs'
Friends = require '../../components/friends'
FindFriends = require '../../components/find_friends'
ProfileDialog = require '../../components/profile_dialog'
AppBar = require '../../components/app_bar'
Icon = require '../../components/icon'
Fab = require '../../components/fab'
ButtonMenu = require '../../components/button_menu'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class FriendsPage
  constructor: ({@model, @router, requests, serverData}) ->
    gameKey = requests.map ({route}) ->
      route.params.gameKey or config.DEFAULT_GAME_KEY
    @isFindFriendsVisible = new Rx.ReplaySubject 1
    @isFindFriendsVisible.next(
      requests.map ({route}) ->
        route.params.action is 'find'
    )
    @selectedProfileDialogUser = new Rx.BehaviorSubject null

    userData = @model.userData.getMe {
      embed: ['following', 'followers', 'blockedUsers']
    }
    following = userData.map ({following}) ->
      following
    followers = userData.map ({followers}) -> followers
    blockedUsers = userData.map ({blockedUsers}) -> blockedUsers

    @$head = new Head({
      @model
      requests
      serverData
      meta: {
        title: 'Friends'
        description: 'Your friends on Clay'
      }
    })
    @$appBar = new AppBar {@model}
    @$buttonMenu = new ButtonMenu {@router, @model}
    @$tabs = new Tabs {@model}
    @$following = new Friends {
      @model, users: following, @selectedProfileDialogUser
    }
    @$followers = new Friends {
      @model, users: followers, @selectedProfileDialogUser
    }
    @$blockedUsers = new Friends {
      @model, users: blockedUsers, @selectedProfileDialogUser
    }
    @$fab = new Fab()
    @$searchIcon = new Icon()
    @$findFriends = new FindFriends {
      @model, @isFindFriendsVisible, @selectedProfileDialogUser
    }
    @$profileDialog = new ProfileDialog {
      @model, @router, @selectedProfileDialogUser, gameKey
    }

    @state = z.state
      isFindFriendsVisible: @isFindFriendsVisible.switch()
      selectedProfileDialogUser: @selectedProfileDialogUser
      windowSize: @model.window.getSize()

  renderHead: (params) =>
    z @$head, params

  render: =>
    {isFindFriendsVisible, selectedProfileDialogUser,
      windowSize} = @state.getValue()

    z '.p-friends', {
      style:
        height: "#{windowSize.height}px"
    },
      z @$appBar,
        isFlat: true
        $topLeftButton: @$buttonMenu
        title: 'Friends'

      z @$tabs,
        isBarFixed: false
        hasAppBar: true
        tabs: [
          {
            $menuText: 'Friends'
            $el:
              z @$following,
                noFriendsMessage:
                  z 'div',
                    z 'div', 'You don\'t have any friends yet.'
                    z 'div', 'Find some pals, it\'ll be fun!'
          }
          {
            $menuText: 'Added me'
            $el:
              z @$followers,
                noFriendsMessage:
                  z 'div',
                    z 'div', 'No one\'s added you yet.'
                    z 'div', 'Get out there and socialize!'
          }
          {
            $menuText: 'Blocked'
            $el:
              z @$blockedUsers,
                noFriendsMessage:
                  z 'div',
                    z 'div', 'You haven\'t blocked anyone yet.'
                    z 'div', 'Awesome :)'
          }
        ]

      if isFindFriendsVisible
        z '.find-friends',
          z @$findFriends,
            isVisible: @isFindFriendsVisible

      if selectedProfileDialogUser
        z @$profileDialog, {user: selectedProfileDialogUser}

      z '.fab',
        z @$fab,
          colors:
            c500: colors.$primary500
          $icon: z @$searchIcon, {
            icon: 'search'
            isTouchTarget: false
            color: colors.$white
          }
          onclick: =>
            @isFindFriendsVisible.next Rx.Observable.of true
