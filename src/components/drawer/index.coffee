z = require 'zorium'
Rx = require 'rx-lite'
_map = require 'lodash/map'
_filter = require 'lodash/filter'
_take = require 'lodash/take'
_isEmpty = require 'lodash/isEmpty'
_orderBy = require 'lodash/orderBy'
Environment = require 'clay-environment'

Icon = require '../icon'
Avatar = require '../avatar'
FlatButton = require '../flat_button'
GroupBadge = require '../group_badge'
Ripple = require '../ripple'
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

GROUPS_IN_DRAWER = 2

module.exports = class Drawer
  constructor: ({@model, @router}) ->
    @$avatar = new Avatar()
    me = @model.user.getMe()
    hasConversations = @model.conversation.getAll().map (conversations) ->
      not _isEmpty conversations

    meAndHasConversations = Rx.Observable.combineLatest(
      me
      hasConversations
      (vals...) -> vals
    )

    myGroups = @model.group.getAll({filter: 'mine'})

    userAgent = navigator?.userAgent
    needsApp = userAgent and
                not Environment.isGameApp(config.GAME_KEY, {userAgent}) and
                not window?.matchMedia('(display-mode: standalone)').matches

    @state = z.state
      isOpen: @model.drawer.isOpen()
      me: me
      myGroups: myGroups.map (groups) =>
        groups = _filter groups, (group) ->
          group?.id isnt '73ed4af0-a2f2-4371-a893-1360d3989708'
        groups = _orderBy groups, (group) ->
          group.conversations?[0]?.lastUpdateTime
        , 'desc'
        _map _take(groups, GROUPS_IN_DRAWER), (group) =>
          {
            group
            $badge: new GroupBadge {@model, group}
            $ripple: new Ripple()
          }
      windowSize: @model.window.getSize()
      drawerWidth: @model.window.getDrawerWidth()
      breakpoint: @model.window.getBreakpoint()

      menuItems: meAndHasConversations.map ([me, hasConversations]) =>
        _filter([
          {
            path: '/profile'
            title: @model.l.get 'drawer.menuItemProfile'
            $icon: new Icon()
            $ripple: new Ripple()
            iconName: 'profile'
          }
          {
            path: '/clan'
            title: @model.l.get 'drawer.menuItemClan'
            $icon: new Icon()
            $ripple: new Ripple()
            iconName: 'clan'
          }
          {
            path: '/decks'
            title: @model.l.get 'drawer.menuItemDecks'
            $icon: new Icon()
            $ripple: new Ripple()
            iconName: 'decks'
          }
          # {
          #   path: '/cards'
          #   title: 'Cards'
          #   $icon: new Icon()
          #   $ripple: new Ripple()
          #   iconName: 'cards'
          # }
          {
            path: '/group/73ed4af0-a2f2-4371-a893-1360d3989708/chat'
            title: @model.l.get 'drawer.menuItemCommunity'
            $icon: new Icon()
            $ripple: new Ripple()
            iconName: 'chat'
          }
          if hasConversations
            {
              path: '/conversations'
              title: @model.l.get 'drawer.menuItemConversations'
              $icon: new Icon()
              $ripple: new Ripple()
              iconName: 'chat-bubble'
            }
          {
            isDivider: true
          }
          {
            path: '/players'
            title: @model.l.get 'drawer.menuItemPlayers'
            $icon: new Icon()
            $ripple: new Ripple()
            iconName: 'friends'
          }
          # {
          #   path: '/events'
          #   title: 'Tournaments'
          #   $icon: new Icon()
          #   $ripple: new Ripple()
          #   iconName: 'trophy'
          # }
          #
          # if me.isMember
          #   {
          #     path: '/friends'
          #     title: 'Friends'
          #     $icon: new Icon()
          #     $ripple: new Ripple()
          #     iconName: 'friends'
          #   }
          # {
          #   path: '/videos'
          #   title: 'Videos'
          #   $icon: new Icon()
          #   $ripple: new Ripple()
          #   iconName: 'video'
          # }
          if needsApp
            {
              isDivider: true
            }
          if needsApp
            {
              onclick: =>
                @model.portal.call 'app.install'
              title: @model.l.get 'drawer.menuItemNeedsApp'
              $icon: new Icon()
              $ripple: new Ripple()
              iconName: 'get'
            }
          # {
          #   path: '/settings'
          #   title: 'Settings'
          #   $icon: new Icon()
          #   $ripple: new Ripple()
          #   iconName: 'settings'
          # }
          ])
          # .concat if me?.username is 'austin' then [
          #   {
          #     onclick: =>
          #       @model.portal.call 'barcode.scan'
          #       .then (code) ->
          #         alert code
          #         console.log code
          #     title: 'Scan Code'
          #     $icon: new Icon()
          #     $ripple: new Ripple()
          #     iconName: 'search'
          #   }
          # ] else []


  render: ({currentPath}) =>
    {isOpen, me, menuItems, myGroups, drawerWidth, breakpoint,
      windowSize} = @state.getValue()

    translateX = if isOpen then '0' else "-#{drawerWidth}px"
    buttonColors =
      c200: colors.$tertiary500
      c500: colors.$tertiary700
      c600: colors.$tertiary700
      c700: colors.$tertiary500

    z '.z-drawer', {
      className: z.classKebab {isOpen}
      style:
        display: if windowSize.width then 'block' else 'none'
        width: if breakpoint is 'mobile' \
               then '100%'
               else "#{drawerWidth}px"
    },
      z '.overlay', {
        ontouchstart: (e) =>
          e?.preventDefault()
          e?.stopPropagation()
          @model.drawer.close()
        onclick: (e) =>
          e?.preventDefault()
          @model.drawer.close()
      }

      z '.drawer', {
        style:
          width: "#{drawerWidth}px"
          transform: "translate(#{translateX}, 0)"
          webkitTransform: "translate(#{translateX}, 0)"
      },
        z '.top',
          z '.header',
            z '.logo'
            z '.beta'
          z '.content',
            z 'ul.menu',
              [
                if me and not me?.isMember
                  [
                    z 'li.sign-in-buttons',
                      z '.button', {
                        onclick: =>
                          @model.signInDialog.open 'signIn'
                      }, @model.l.get 'general.signIn'
                      z '.button', {
                        onclick: =>
                          @model.signInDialog.open()
                      }, @model.l.get 'general.signUp'
                    z '.divider'
                  ]
                _map myGroups, ({$badge, $ripple, group}) =>
                  isSelected = currentPath?.indexOf("/group/#{group.id}") is 0
                  z 'li.menu-item', {
                    className: z.classKebab {isSelected}
                  },
                    z 'a.menu-item-link', {
                      href: "/group/#{group.id}/chat"
                      onclick: (e) =>
                        e.preventDefault()
                        @model.drawer.close()
                        @router.go "/group/#{group.id}/chat"
                    },
                      z '.icon',
                        z $badge
                      @model.group.getDisplayName group
                      $ripple

                unless _isEmpty myGroups
                  z '.divider'

                _map menuItems, (menuItem) =>
                  {path, onclick, title, $icon, $ripple,
                    iconName, isDivider} = menuItem

                  if isDivider
                    return z 'li.divider'

                  isSelected = currentPath?.indexOf(path) is 0 or (
                    path is '/community' and currentPath is '/'
                  )
                  z 'li.menu-item', {
                    className: z.classKebab {isSelected}
                  },
                    z 'a.menu-item-link', {
                      href: path
                      onclick: (e) =>
                        e.preventDefault()
                        @model.drawer.close()
                        onclick?()
                        if path
                          @router.go path
                    },
                      z '.icon',
                        z $icon,
                          isTouchTarget: false
                          icon: iconName
                          color: colors.$primary500
                      title
                      z $ripple
              ]
