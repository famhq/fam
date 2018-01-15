z = require 'zorium'
_map = require 'lodash/map'
_filter = require 'lodash/filter'
RxObservable = require('rxjs/Observable').Observable
require 'rxjs/add/observable/combineLatest'

Icon = require '../icon'
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

GROUPS_IN_DRAWER = 2

module.exports = class BottomBar
  constructor: ({@model, @router, requests, group}) ->
    gameKey = requests.map ({route}) ->
      route.params.gameKey
    language = @model.l.getLanguage()

    gameKeyAndLanguage = RxObservable.combineLatest(
      gameKey, language, (vals...) -> vals
    )

    @state = z.state
      requests: requests
      language: language
      group: group or gameKeyAndLanguage.switchMap ([gameKey, language]) =>
        if gameKey and language
          @model.group.getByGameKeyAndLanguage gameKey, language
        else
          RxObservable.of null

      gameKey: gameKey

  render: =>
    {requests, language, gameKey, group} = @state.getValue()
    currentPath = requests?.req.path

    gameKey or= config.DEFAULT_GAME_KEY

    # per-group menu:
    # profile, tools, home, forum, chat
    @menuItems = _filter [
      {
        $icon: new Icon()
        icon: 'profile'
        route: @router.get 'profile', {gameKey}
        text: @model.l.get 'general.profile'
      }
      {
        $icon: new Icon()
        icon: 'chat'
        # route: @router.get '+groupChat', {groupId: 'playhard'}
        route: @router.get 'chat', {gameKey}
        text: @model.l.get 'general.chat'
      }
      {
        $icon: new Icon()
        icon: 'home'
        route: @router.get '+groupHome', {
          groupId: group?.key or config.CLASH_ROYALE_ID
        }
        text: @model.l.get 'general.home'
        isDefault: true
      }
      {
        $icon: new Icon()
        icon: 'rss'
        # route: @router.get '+groupForum', {groupId: 'playhard'}
        route: @router.get 'forum', {gameKey}
        text: @model.l.get 'general.forum'
      }
      {
        $icon: new Icon()
        icon: 'ellipsis'
        route: @router.get 'mods', {gameKey}
        text: @model.l.get 'general.tools'
      }
    ]

    z '.z-bottom-bar', {key: 'bottom-bar'},
      _map @menuItems, ({$icon, icon, route, text, $ripple, isDefault}, i) =>
        if isDefault
          isSelected =  currentPath in [
            @router.get 'siteHome'
            @router.get 'home', {gameKey}
            @router.get '+groupHome', {
              gameKey, groupId: group?.key or group?.id
            }
            '/'
          ]
        else
          isSelected = currentPath and currentPath.indexOf(route) isnt -1

        z 'a.menu-item', {
          attributes:
            tabindex: i
          className: z.classKebab {isSelected}
          href: route
          onclick: (e) =>
            e?.preventDefault()
            @router.goPath route
          # ontouchstart: (e) =>
          #   e?.stopPropagation()
          #   @router.goPath route
          # onclick: (e) =>
          #   e?.stopPropagation()
          #   @router.goPath route
        },
          z '.icon',
            z $icon,
              icon: icon
              color: if isSelected then colors.$primary500 else colors.$white54
              isTouchTarget: false
          z '.text', text
