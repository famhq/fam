z = require 'zorium'
_map = require 'lodash/map'
_filter = require 'lodash/filter'

Icon = require '../icon'
Ripple = require '../ripple'
colors = require '../../colors'

if window?
  require './index.styl'

GROUPS_IN_DRAWER = 2

module.exports = class BottomBar
  constructor: ({@model, @router, requests}) ->
    @state = z.state
      requests: requests
      language: @model.l.getLanguage()

  render: =>
    {requests, language} = @state.getValue()
    currentPath = requests?.req.path

    @menuItems = _filter [
      {
        $icon: new Icon()
        icon: 'profile'
        route: '/profile'
        text: @model.l.get 'general.profile'
      }
      {
        $icon: new Icon()
        icon: 'clan'
        route: '/clan'
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
        route: '/addons'
        text: @model.l.get 'general.tools'
      }
      {
        $icon: new Icon()
        icon: 'chat'
        route: '/social'
        text: @model.l.get 'general.chat'
      }

      if window? and language is 'es'
        {
          $icon: new Icon()
          icon: 'rss'
          route: '/forum'
          text: @model.l.get 'general.forum'
        }
    ]

    z '.z-bottom-bar',
      _map @menuItems, ({$icon, icon, route, text}) =>
        isSelected = currentPath and (currentPath.indexOf(route) isnt -1 or (
          currentPath is '/' and route is '/profile'
        ))

        z '.menu-item', {
          className: z.classKebab {isSelected}
          onclick: =>
            @router.go route
        },
          z '.icon',
            z $icon,
              icon: icon
              color: if isSelected then colors.$primary500 else colors.$white54
              isTouchTarget: false
          z '.text', text
