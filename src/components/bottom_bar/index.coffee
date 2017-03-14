z = require 'zorium'
_map = require 'lodash/map'

Icon = require '../icon'
Ripple = require '../ripple'
colors = require '../../colors'

if window?
  require './index.styl'

GROUPS_IN_DRAWER = 2

module.exports = class BottomBar
  constructor: ({@model, @router, requests}) ->
    @menuItems = [
      {
        $icon: new Icon()
        icon: 'profile'
        route: '/profile'
        text: 'Profile'
      }
      {
        $icon: new Icon()
        icon: 'decks'
        route: '/decks'
        text: 'Decks'
      }
      # {
      #   $icon: new Icon()
      #   icon: 'cards'
      #   route: '/cards'
      #   text: 'Cards'
      # }
      {
        $icon: new Icon()
        icon: 'chat'
        route: '/group/73ed4af0-a2f2-4371-a893-1360d3989708/chat'
        text: 'Chat'
      }
    ]

    @state = z.state {requests}


  render: =>
    {requests} = @state.getValue()
    currentPath = requests?.req.path

    z '.z-bottom-bar',
      _map @menuItems, ({$icon, icon, route, text}) =>
        isSelected = currentPath?.indexOf(route) isnt -1 or (
          currentPath is '/' and route is '/profile'
        )

        z '.menu-item', {
          className: z.classKebab {isSelected}
          onclick: =>
            @router.go route
        },
          z '.icon',
            z $icon,
              icon: icon
              color: if isSelected then colors.$primary500 else colors.$white34
              isTouchTarget: false
          z '.text', text
