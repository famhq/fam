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
    @state = z.state {requests}

    @expDecksPageGroup = localStorage?['exp:decksPage']
    unless @expDecksPageGroup
      @expDecksPageGroup = if Math.random() > 0.5 \
                               then 'visible'
                               else 'hidden'
      localStorage?['exp:decksPage'] = @expDecksPageGroup
    ga? 'send', 'event', 'exp', 'decksPage', @expDecksPageGroup

    @expVideosPageGroup = localStorage?['exp:videosPage']
    unless @expVideosPageGroup
      @expVideosPageGroup = if Math.random() > 0.5 \
                               then 'visible'
                               else 'hidden'
      localStorage?['exp:videosPage'] = @expVideosPageGroup
    ga? 'send', 'event', 'exp', 'videosPage', @expVideosPageGroup

    @expSocialGroup = localStorage?['exp:videosPage']
    unless @expSocialGroup
      @expSocialGroup = if Math.random() > 0.5 \
                               then 'visible'
                               else 'control'
      localStorage?['exp:videosPage'] = @expSocialGroup
    ga? 'send', 'event', 'exp', 'social', @expSocialGroup


  render: =>
    {requests} = @state.getValue()
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
      if window? and @expDecksPageGroup is 'visible'
        {
          $icon: new Icon()
          icon: 'decks'
          route: '/decks'
          text: @model.l.get 'general.decks'
        }
      if window? and @model.l.language is 'es' and @expVideosPageGroup is 'visible'
        {
          $icon: new Icon()
          icon: 'video'
          route: '/videos'
          text: 'Videos'
        }
      # if expSocialGroup is 'visible'
      #   {
      #     $icon: new Icon()
      #     icon: 'chat'
      #     route: '/social'
      #     text: @model.l.get 'general.social'
      #   }
      # else
      {
        $icon: new Icon()
        icon: 'chat'
        route: '/group/73ed4af0-a2f2-4371-a893-1360d3989708/chat'
        text: @model.l.get 'general.chat'
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
