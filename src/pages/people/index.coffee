z = require 'zorium'
_map = require 'lodash/map'
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject
RxReplaySubject = require('rxjs/ReplaySubject').ReplaySubject
RxObservable = require('rxjs/Observable').Observable
require 'rxjs/add/observable/of'

Tabs = require '../../components/tabs'
People = require '../../components/people'
FindPeople = require '../../components/find_people'
ProfileDialog = require '../../components/profile_dialog'
AppBar = require '../../components/app_bar'
Icon = require '../../components/icon'
Fab = require '../../components/fab'
ButtonMenu = require '../../components/button_menu'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class PeoplePage
  @hasBottomBar: true

  constructor: ({@model, @router, requests, serverData, group, @$bottomBar}) ->
    @selectedProfileDialogUser = new RxBehaviorSubject null
    selectedIndex = new RxBehaviorSubject 0

    following = @model.userFollower.getAllFollowing()
    .map (userFollowers) -> _map userFollowers, 'user'
    followers = @model.userFollower.getAllFollowers()
    .map (userFollowers) -> _map userFollowers, 'user'
    blockedUsers = @model.userBlock.getAll()
    .map (userBlocks) -> _map userBlocks, 'user'

    @$appBar = new AppBar {@model}
    @$buttonMenu = new ButtonMenu {@router, @model}
    @$tabs = new Tabs {@model, selectedIndex}
    @$following = new People {
      @model, users: following, @selectedProfileDialogUser
    }
    @$followers = new People {
      @model, users: followers, @selectedProfileDialogUser
    }
    @$blockedUsers = new People {
      @model, users: blockedUsers, @selectedProfileDialogUser
    }
    @$fab = new Fab()
    @$addIcon = new Icon()
    @$findPeople = new FindPeople {
      @model, @router, group, @selectedProfileDialogUser
    }
    @$profileDialog = new ProfileDialog {
      @model, @router, @selectedProfileDialogUser
    }

    @state = z.state
      selectedProfileDialogUser: @selectedProfileDialogUser
      selectedIndex: selectedIndex
      group: group
      windowSize: @model.window.getSize()

  getMeta: =>
    {
      title: @model.l.get 'groupPeoplePage.title'
      description: @model.l.get 'groupPeoplePage.description'
    }

  render: =>
    {isCreateLfgVisible, selectedProfileDialogUser, selectedIndex, group
      windowSize} = @state.getValue()

    z '.p-people', {
      style:
        height: "#{windowSize.height}px"
    },
      z @$appBar,
        isFlat: true
        $topLeftButton: @$buttonMenu
        title: @model.l.get 'people.title'

      z @$tabs,
        isBarFixed: false
        hasAppBar: true
        tabs: [
          {
            $menuText: @model.l.get 'general.search'
            $el:
              z @$findPeople
          }
          {
            $menuText: @model.l.get 'people.following'
            $el:
              z @$following,
                noPeopleMessage:
                  z 'div',
                    z 'div', @model.l.get 'people.followingEmpty'
          }
          {
            $menuText: @model.l.get 'people.followers'
            $el:
              z @$followers,
                noPeopleMessage:
                  z 'div',
                    z 'div', @model.l.get 'people.followersEmpty'
          }
          # {
          #   $menuText: @model.l.get 'people.blocked'
          #   $el:
          #     z @$blockedUsers,
          #       noPeopleMessage:
          #         z 'div',
          #           z 'div', @model.l.get 'people.blockedEmpty'
          # }
        ]

      z @$bottomBar

      if selectedProfileDialogUser
        z @$profileDialog, {user: selectedProfileDialogUser}

      if selectedIndex is 0 and @model.experiment.get('lfgNewButton') is 'control'
        z '.fab',
          z @$fab,
            colors:
              c500: colors.$primary500
            $icon: z @$addIcon, {
              icon: 'add'
              isTouchTarget: false
              color: colors.$primary500Text
            }
            onclick: =>
              @model.group.goPath group, 'groupNewLfg', {@router}
