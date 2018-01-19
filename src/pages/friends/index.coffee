z = require 'zorium'
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject
RxReplaySubject = require('rxjs/ReplaySubject').ReplaySubject
RxObservable = require('rxjs/Observable').Observable
require 'rxjs/add/observable/of'

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
  constructor: ({@model, @router, requests, serverData, group}) ->
    @isFindFriendsVisible = new RxReplaySubject 1
    @isFindFriendsVisible.next(
      requests.map ({route}) ->
        route.params.action is 'find'
    )
    @selectedProfileDialogUser = new RxBehaviorSubject null

    userData = @model.userData.getMe {
      embed: ['following', 'followers', 'blockedUsers']
    }
    following = userData.map ({following}) ->
      following
    followers = userData.map ({followers}) -> followers
    blockedUsers = userData.map ({blockedUsers}) -> blockedUsers

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
      @model, @router, @selectedProfileDialogUser
    }

    @state = z.state
      isFindFriendsVisible: @isFindFriendsVisible.switch()
      selectedProfileDialogUser: @selectedProfileDialogUser
      windowSize: @model.window.getSize()

  getMeta: =>
    {
      title: 'Friends'
      description: 'Your friends on Clay'
    }

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
            color: colors.$primary500Text
          }
          onclick: =>
            @isFindFriendsVisible.next RxObservable.of true
