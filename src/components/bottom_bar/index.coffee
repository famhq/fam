z = require 'zorium'
_map = require 'lodash/map'
_filter = require 'lodash/filter'

Icon = require '../icon'
Ripple = require '../ripple'
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

GROUPS_IN_DRAWER = 2

module.exports = class BottomBar
  constructor: ({@model, @router, requests}) ->
    @state = z.state
      requests: requests
      language: @model.l.getLanguage()
      gameKey: requests.map ({route}) ->
        route.params.gameKey or config.DEFAULT_GAME_KEY

  render: =>
    {requests, language, gameKey} = @state.getValue()
    currentPath = requests?.req.path

    @menuItems = _filter [
      {
        $icon: new Icon()
        icon: 'profile'
        route: @router.get 'home', {gameKey}
        text: @model.l.get 'general.profile'
        isDefault: true
      }
      {
        $icon: new Icon()
        icon: 'clan'
        route: @router.get 'clan', {gameKey}
        text: @model.l.get 'general.clan'
      }
      # {
      #   $icon: new Icon()
      #   icon: 'friends'
      #   route: '/players'
      #   text: @model.l.get 'drawer.menuItemPlayers'
      # }
      {
        $icon: new Icon()
        icon: 'ellipsis'
        route: @router.get 'mods', {gameKey}
        text: @model.l.get 'general.tools'
      }
      {
        $icon: new Icon()
        icon: 'chat'
        route: @router.get 'chat', {gameKey}
        text: @model.l.get 'general.chat'
      }

      if window? and language in config.COMMUNITY_LANGUAGES
        {
          $icon: new Icon()
          icon: 'rss'
          route: @router.get 'forum', {gameKey}
          text: @model.l.get 'general.forum'
        }
    ]

    z '.z-bottom-bar',
      _map @menuItems, ({$icon, icon, route, text, isDefault}) =>
        if isDefault
          isSelected =  currentPath in [
            @router.get 'siteHome'
            @router.get 'home', {gameKey}
            '/'
          ]
        else
          isSelected = currentPath and currentPath.indexOf(route) isnt -1

        z '.menu-item', {
          className: z.classKebab {isSelected}
          onclick: =>
            @router.goPath route
        },
          z '.icon',
            z $icon,
              icon: icon
              color: if isSelected then colors.$primary500 else colors.$white54
              isTouchTarget: false
          z '.text', text
