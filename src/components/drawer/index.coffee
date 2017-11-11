z = require 'zorium'
_map = require 'lodash/map'
_filter = require 'lodash/filter'
_take = require 'lodash/take'
_isEmpty = require 'lodash/isEmpty'
_orderBy = require 'lodash/orderBy'
Environment = require 'clay-environment'
semver = require 'semver'
RxObservable = require('rxjs/Observable').Observable
require 'rxjs/add/observable/combineLatest'
require 'rxjs/add/operator/map'

Icon = require '../icon'
Avatar = require '../avatar'
FlatButton = require '../flat_button'
AdsenseAd = require '../adsense_ad'
ClanBadge = require '../clan_badge'
GroupBadge = require '../group_badge'
SetLanguageDialog = require '../set_language_dialog'
Ripple = require '../ripple'
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

GROUPS_IN_DRAWER = 2

module.exports = class Drawer
  constructor: ({@model, @router, gameKey, group, @overlay$}) ->
    @$avatar = new Avatar()
    @$adsenseAd = new AdsenseAd {@model}

    me = @model.user.getMe()
    meAndLanguageAndGameKey = RxObservable.combineLatest(
      me
      @model.l.getLanguage()
      gameKey
      (vals...) -> vals
    )

    myGroups = @model.group.getAll({filter: 'mine'})
    groupAndMyGroupsAndGameKey = RxObservable.combineLatest(
      group
      myGroups
      gameKey
      (vals...) -> vals
    )

    userAgent = navigator?.userAgent
    needsApp = userAgent and
                not Environment.isGameApp(config.GAME_KEY, {userAgent}) and
                not window?.matchMedia('(display-mode: standalone)').matches

    @state = z.state
      isOpen: @model.drawer.isOpen()
      language: @model.l.getLanguage()
      me: me
      gameKey: gameKey
      myGroups: groupAndMyGroupsAndGameKey.map ([group, groups, gameKey]) =>
        groups = _orderBy groups, (group) ->
          group.conversations?[0]?.lastUpdateTime
        , 'desc'
        if group # current group, show up top
          groups = _filter groups, ({id}) ->
            id isnt group.id
          groups = [group].concat groups
        _map _take(groups, GROUPS_IN_DRAWER), (group) =>
          {
            group
            $badge: if group.clan \
                    then new ClanBadge {@model, clan: group.clan}
                    else new GroupBadge {@model, group}
            $chevronIcon: new Icon()
            $ripple: new Ripple()
            children: if group.id is 'ad25e866-c187-44fc-bdb5-df9fcc4c6a42'
              [
                {
                  path: @router.get 'groupChat', {
                    gameKey: gameKey
                    id: group.id
                  }
                  title: @model.l.get 'general.chat'
                }
                {
                  path: @router.get 'groupShop', {
                    gameKey: gameKey
                    id: group.id
                  }
                  title: @model.l.get 'general.shop'
                }
                {
                  path: @router.get 'groupVideos', {
                    gameKey: gameKey
                    id: group.id
                  }
                  title: @model.l.get 'videosPage.title'
                }
              ]
          }
      windowSize: @model.window.getSize()
      drawerWidth: @model.window.getDrawerWidth()
      breakpoint: @model.window.getBreakpoint()

      menuItems: meAndLanguageAndGameKey.map ([me, language, gameKey]) =>
        _filter([
          {
            path: @router.get 'home', {gameKey}
            title: @model.l.get 'drawer.menuItemProfile'
            $icon: new Icon()
            $ripple: new Ripple()
            iconName: 'profile'
            isDefault: true
          }
          {
            path: @router.get 'clan', {gameKey}
            title: @model.l.get 'drawer.menuItemClan'
            $icon: new Icon()
            $ripple: new Ripple()
            iconName: 'clan'
          }
          {
            path: @router.get 'chat', {gameKey}
            title: @model.l.get 'general.chat'
            $icon: new Icon()
            $ripple: new Ripple()
            iconName: 'chat'
          }
          if language in config.COMMUNITY_LANGUAGES
            {
              path: @router.get 'forum', {gameKey}
              title: @model.l.get 'general.forum'
              $icon: new Icon()
              $ripple: new Ripple()
              iconName: 'rss'
            }

          {
            isDivider: true
          }
          {
            path: @router.get 'mods', {gameKey}
            title: @model.l.get 'addonsPage.title'
            $icon: new Icon()
            $ripple: new Ripple()
            iconName: 'ellipsis'
          }
          {
            path: @router.get 'fire', {gameKey}
            title: @model.l.get 'firePage.title'
            $icon: new Icon()
            $ripple: new Ripple()
            iconName: 'fire'
            isNew: true
          }
          {
            path: @router.get 'players', {gameKey}
            title: @model.l.get 'drawer.menuItemPlayers'
            $icon: new Icon()
            $ripple: new Ripple()
            iconName: 'friends'
          }
          if language is 'es'
            {
              path: 'https://starfire.games/es/clash-royale/wiki'
              onclick: (e) =>
                e?.preventDefault()
                isNative = Environment.isGameApp config.GAME_KEY
                appVersion = isNative and Environment.getAppVersion(
                  config.GAME_KEY
                )
                isNewIAB = isNative and semver.gte appVersion, '1.4.0'
                @model.portal.call 'browser.openWindow', {
                  url: 'https://starfire.games/es/clash-royale/wiki'
                  target: '_blank'
                  options: if isNewIAB
                    statusbar: {
                      color: colors.$primary700
                    }
                    toolbar: {
                      height: 56
                      color: colors.$tertiary700
                    }
                    title: {
                      color: colors.$tertiary700Text
                      staticText: 'Wiki'
                    }
                    closeButton: {
                      # https://jgilfelt.github.io/AndroidAssetStudio/icons-launcher.html#foreground.type=clipart&foreground.space.trim=1&foreground.space.pad=0.5&foreground.clipart=res%2Fclipart%2Ficons%2Fnavigation_close.svg&foreColor=fff%2C0&crop=0&backgroundShape=none&backColor=fff%2C100&effects=none&elevate=0
                      image: 'close'
                      # imagePressed: 'close_grey'
                      align: 'left'
                      event: 'closePressed'
                    }
                }
              title: 'Wiki'
              $icon: new Icon()
              $ripple: new Ripple()
              iconName: 'wiki'
            }
          {
            path: @router.get 'recruit', {gameKey}
            title: @model.l.get 'general.recruiting'
            $icon: new Icon()
            $ripple: new Ripple()
            iconName: 'recruit'
          }

          # {
          #   onclick: =>
          #     @model.portal.call 'browser.openWindow', {
          #       url: 'https://github.com/starfirehq/starfire-sdk'
          #       target: '_system'
          #     }
          #   title: @model.l.get 'general.developers'
          #   $icon: new Icon()
          #   $ripple: new Ripple()
          #   iconName: 'developers'
          # }
          if me?.flags.isModerator
            {
              path: @router.get 'modHub', {gameKey}
              title: 'Mod hub'
              $icon: new Icon()
              $ripple: new Ripple()
              iconName: 'edit'
            }
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

  render: ({currentPath}) =>
    {isOpen, me, menuItems, myGroups, drawerWidth, breakpoint, gameKey,
      language, windowSize} = @state.getValue()

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
            z '.language', {
              onclick: =>
                @overlay$.next new SetLanguageDialog {
                  @model, @router, @overlay$
                }
            },
              language
              z '.arrow'
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
                _map myGroups, (myGroup) =>
                  {$badge, $ripple, group, $chevronIcon, children} = myGroup
                  groupPath = @router.get 'group', {gameKey, id: group.id}
                  groupEnPath = @router.get 'group', {gameKey, id: group.id}, {
                    language: 'en'
                  }
                  isSelected = currentPath?.indexOf(groupPath) is 0 or
                    currentPath?.indexOf(groupEnPath) is 0
                  z 'li.menu-item', {
                    className: z.classKebab {isSelected}
                  },
                    z 'a.menu-item-link', {
                      href: groupPath
                      onclick: (e) =>
                        e.preventDefault()
                        @model.drawer.close()
                        @router.go 'groupChat', {gameKey, id: group.id}
                    },
                      z '.icon',
                        z $badge
                      @model.group.getDisplayName group
                      if not _isEmpty children
                        z '.chevron',
                          z $chevronIcon,
                            icon: if isSelected \
                                  then 'chevron-up'
                                  else 'chevron-down'
                            color: colors.$tertiary500Text70
                            isTouchTarget: false
                      $ripple
                    if isSelected
                      z 'ul',
                        _map children, ({path, title}) =>
                          isSelected = currentPath?.indexOf(path) is 0
                          z 'li.menu-item',
                            z 'a.menu-item-link.is-child', {
                              className: z.classKebab {isSelected}
                              href: path
                              onclick: (e) =>
                                e.preventDefault()
                                @model.drawer.close()
                                @router.goPath path
                            },
                              z '.icon'
                              title


                unless _isEmpty myGroups
                  z '.divider'

                _map menuItems, (menuItem) =>
                  {path, onclick, title, $icon, $ripple, isNew,
                    iconName, isDivider} = menuItem

                  if isDivider
                    return z 'li.divider'

                  if menuItem.isDefault
                    isSelected = currentPath in [
                      @router.get 'siteHome'
                      @router.get 'home', {gameKey}
                      '/'
                    ]
                  else
                    isSelected = currentPath?.indexOf(path) is 0
                  z 'li.menu-item', {
                    className: z.classKebab {isSelected}
                  },
                    z 'a.menu-item-link', {
                      href: path
                      onclick: (e) =>
                        e.preventDefault()
                        @model.drawer.close()
                        if onclick
                          onclick()
                        else if path
                          @router.goPath path
                    },
                      z '.icon',
                        z $icon,
                          isTouchTarget: false
                          icon: iconName
                          color: colors.$primary500
                      title
                      if isNew
                        z '.new', @model.l.get 'general.new'
                      z $ripple
              ]

          if not Environment.isMobile() and windowSize?.height > 880
            z '.ad',
              z @$adsenseAd, {
                slot: 'desktop336x280'
              }
