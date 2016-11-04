z = require 'zorium'
Rx = require 'rx-lite'
Button = require 'zorium-paper/button'
_ = require 'lodash'
moment = require 'moment'

Icon = require '../icon'
Avatar = require '../avatar'
DeckCards = require '../deck_cards'
FlatButton = require '../flat_button'
colors = require '../../colors'

if window?
  require './index.styl'

DRAWER_RIGHT_PADDING = 56
DRAWER_MAX_WIDTH = 336

module.exports = class Drawer
  constructor: ({@model, @router}) ->
    @$avatar = new Avatar()
    me = @model.user.getMe()

    userDeck = me.flatMapLatest (me) =>
      if me?.data?.clashRoyaleDeckId
        @model.clashRoyaleUserDeck.getByDeckId me?.data?.clashRoyaleDeckId
      else
        Rx.Observable.just null

    @$deckCards = new DeckCards {
      @model, @router
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

    @state = z.state
      isOpen: @model.drawer.isOpen()
      me: me
      userDeck: userDeck
      isAddWinLoading: false
      isAddLossLoading: false
      isAddDrawLoading: false

      menuItems: me.map (me) =>
        if not me.isMember
          [
            {
              path: '/signIn'
              title: 'Sign In'
              $icon: new Icon()
              iconName: 'profile'
            }
            {
              path: '/'
              title: 'Request Invite'
              $icon: new Icon()
              iconName: 'friends'
            }

          ]
        else
          [
            {
              path: '/profile'
              title: 'Profile'
              $icon: new Icon()
              iconName: 'profile'
            }
            {
              path: '/threads'
              title: 'Community'
              $icon: new Icon()
              iconName: 'chat'
            }
            # {
            #   onClick: =>
            #     @model.portal.call 'barcode.scan'
            #     .then (code) ->
            #       alert code
            #       console.log code
            #   title: 'Scan Code'
            #   $icon: new Icon()
            #   iconName: 'search'
            # }
            # {
            #   path: '/members'
            #   title: 'Members'
            #   $icon: new Icon()
            #   iconName: 'friends'
            # }
            {
              path: '/decks'
              title: 'Battle Decks'
              $icon: new Icon()
              iconName: 'decks'
            }
            {
              path: '/cards'
              title: 'Battle Cards'
              $icon: new Icon()
              iconName: 'cards'
            }
            # {
            #   isDivider: true
            # }
            {
              path: '/refer'
              title: 'Refer a member'
              $icon: new Icon()
              iconName: 'gem'
            }
            # {
            #   path: '/settings'
            #   title: 'Settings'
            #   $icon: new Icon()
            #   iconName: 'settings'
            # }
          ]
          .concat if me?.username is 'austin' then [
            {
              onClick: =>
                @model.portal.call 'barcode.scan'
                .then (code) ->
                  alert code
                  console.log code
              title: 'Scan Code'
              $icon: new Icon()
              iconName: 'search'
            }
          ] else []


  render: ({currentPath}) =>
    {isOpen, me, menuItems, userDeck, isAddWinLoading, isAddLossLoading,
      isAddDrawLoading} = @state.getValue()

    deck = userDeck?.deck

    drawerWidth = Math.min \
      window?.innerWidth - DRAWER_RIGHT_PADDING, DRAWER_MAX_WIDTH
    translateX = if isOpen then '0' else "-#{drawerWidth}px"
    buttonColors =
      c200: colors.$tertiary700
      c500: colors.$tertiary500
      c600: colors.$tertiary900
      c700: colors.$tertiary700

    z '.z-drawer', {
      className: z.classKebab {isOpen}
      style:
        display: if window? then 'block' else 'none'
    },
      z '.overlay', {
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
        z '.header',
          z '.logo'
        z '.content',
          z 'ul.menu',
            _.map menuItems, (menuItem) =>
              {path, onClick, title, $icon, iconName, isDivider} = menuItem
              if isDivider
                return z 'li.divider'
              isSelected = currentPath?.indexOf(path) is 0 or (
                path is '/games' and currentPath is '/'
              )
              z 'li.menu-item', {
                className: z.classKebab {isSelected}
              },
                z 'a.menu-item-link', {
                  href: path
                  onclick: (e) =>
                    e.preventDefault()
                    @model.drawer.close()
                    onClick?()
                    if path
                      @router.go path
                },
                  z '.icon',
                    z $icon,
                      isTouchTarget: false
                      icon: iconName
                      color: colors.$primary500
                  title
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
              z @$deckCards,
                cardsPerRow: 4
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
