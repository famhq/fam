z = require 'zorium'
Rx = require 'rx-lite'
_map = require 'lodash/map'
_filter = require 'lodash/filter'
_take = require 'lodash/take'
_isEmpty = require 'lodash/isEmpty'
Environment = require 'clay-environment'

Icon = require '../icon'
Avatar = require '../avatar'
DeckCards = require '../deck_cards'
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

    userDeck = me.flatMapLatest (me) =>
      if me?.data?.clashRoyaleDeckId
        @model.clashRoyaleUserDeck.getByDeckId me?.data?.clashRoyaleDeckId
      else
        Rx.Observable.just null

    myGroups = @model.group.getAll({filter: 'mine'})

    @$deckCards = new DeckCards {
      @model, @router
      cardsPerRow: 4
      deck: userDeck.map (userDeck) ->
        userDeck?.deck
    }
    @$setDeckButton = new FlatButton()
    @$setDeckIcon = new Icon()
    @$addWinButton = new FlatButton()
    @$addWinIcon = new Icon()
    @$addLossButton = new FlatButton()
    @$addLossIcon = new Icon()
    @$addDrawButton = new FlatButton()
    @$addDrawIcon = new Icon()

    userAgent = navigator?.userAgent
    needsApp = userAgent and
                not Environment.isGameApp(config.GAME_KEY, {userAgent}) and
                not window?.matchMedia('(display-mode: standalone)').matches

    @state = z.state
      isOpen: @model.drawer.isOpen()
      me: me
      myGroups: myGroups.map (groups) =>
        _map _take(groups, GROUPS_IN_DRAWER), (group) =>
          {
            group
            $badge: new GroupBadge {@model, group}
            $ripple: new Ripple()
          }
      userDeck: userDeck
      isAddWinLoading: false
      isAddLossLoading: false
      isAddDrawLoading: false
      drawerWidth: @model.window.getDrawerWidth()
      breakpoint: @model.window.getBreakpoint()

      menuItems: me.map (me) =>
        _filter([
          {
            path: '/community'
            title: 'Community'
            $icon: new Icon()
            $ripple: new Ripple()
            iconName: 'chat'
          }
          {
            path: '/events'
            title: 'Tournaments'
            $icon: new Icon()
            $ripple: new Ripple()
            iconName: 'trophy'
          }

          if me.isMember
            {
              path: '/friends'
              title: 'Friends'
              $icon: new Icon()
              $ripple: new Ripple()
              iconName: 'friends'
            }
          {
            path: '/videos'
            title: 'Videos'
            $icon: new Icon()
            $ripple: new Ripple()
            iconName: 'video'
          }
          {
            path: '/decks'
            title: 'Battle Decks'
            $icon: new Icon()
            $ripple: new Ripple()
            iconName: 'decks'
          }
          {
            path: '/cards'
            title: 'Battle Cards'
            $icon: new Icon()
            $ripple: new Ripple()
            iconName: 'cards'
          }
          if me.isMember
            {
              path: '/profile'
              title: 'Profile'
              $icon: new Icon()
              $ripple: new Ripple()
              iconName: 'profile'
            }
          if needsApp
            {
              isDivider: true
            }
          if needsApp
            {
              onclick: =>
                @model.portal.call 'app.install'
              title: 'Get the app'
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
    {isOpen, me, menuItems, userDeck, isAddWinLoading, isAddLossLoading,
      isAddDrawLoading, myGroups, drawerWidth, breakpoint} = @state.getValue()
    deck = userDeck?.deck

    translateX = if isOpen then '0' else "-#{drawerWidth}px"
    buttonColors =
      c200: colors.$tertiary500
      c500: colors.$tertiary700
      c600: colors.$tertiary700
      c700: colors.$tertiary500

    z '.z-drawer', {
      className: z.classKebab {isOpen}
      style:
        display: if window? then 'block' else 'none'
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
            if me and not me?.isMember
              z '.sign-in',
                z '.sign-in-button', {
                  onclick: =>
                    @model.signInDialog.open()
                }, 'Sign in'
          z '.content',
            z 'ul.menu',
              [
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
                    path is '/decks' and currentPath is '/'
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
        if me?.isMember and not userDeck
          z '.no-deck',
            z '.set-deck-button',
              z @$setDeckButton,
                colors: buttonColors
                isFullWidth: false
                onclick: =>
                  @model.drawer.close()
                  @router.go '/decks'
                text:
                  z '.z-drawer_set-deck-button',
                    z @$setDeckIcon,
                      icon: 'check'
                      isTouchTarget: false
                      color: colors.$primary500
                    z '.text', 'Set current deck'
            z '.description',
              'Set your current deck to easily track new wins, losses, or draws'
        else if me?.isMember
          z '.deck',
            z '.deck-cards',
              z @$deckCards
              z '.stats',
                "W#{userDeck?.wins or 0} /
                L#{userDeck?.losses or 0} /
                D#{userDeck?.draws or 0}"
            z '.buttons',
              z '.button',
                z @$addWinButton,
                  colors: buttonColors
                  onclick: =>
                    @state.set isAddWinLoading: true
                    @model.clashRoyaleUserDeck.incrementByDeckId(
                      deck.id
                      {state: 'win'}
                    )
                    .catch -> null
                    .then =>
                      @state.set isAddWinLoading: false
                  text: z '.z-drawer_button',
                    z '.icon',
                      z @$addWinIcon,
                        icon: 'add'
                        color: colors.$primary500
                        isTouchTarget: false
                    z '.text', if isAddWinLoading then '...' else 'Win'

              z '.button',
                z @$addLossButton,
                  colors: buttonColors
                  onclick: =>
                    @state.set isAddLossLoading: true
                    @model.clashRoyaleUserDeck.incrementByDeckId(
                      deck.id
                      {state: 'loss'}
                    )
                    .catch -> null
                    .then =>
                      @state.set isAddLossLoading: false
                  text: z '.z-drawer_button',
                    z '.icon',
                      z @$addLossIcon,
                        icon: 'add'
                        color: colors.$primary500
                        isTouchTarget: false
                    z '.text', if isAddLossLoading then '...' else 'Loss'

              z '.button',
                z @$addDrawButton,
                  colors: buttonColors
                  onclick: =>
                    @state.set isAddDrawLoading: true
                    @model.clashRoyaleUserDeck.incrementByDeckId(
                      deck.id
                      {state: 'draw'}
                    )
                    .catch -> null
                    .then =>
                      @state.set isAddDrawLoading: false
                  text: z '.z-drawer_button',
                    z '.icon',
                      z @$addDrawIcon,
                        icon: 'add'
                        color: colors.$primary500
                        isTouchTarget: false
                    z '.text', if isAddDrawLoading then '...' else 'Draw'
