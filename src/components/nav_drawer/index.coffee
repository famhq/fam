z = require 'zorium'
_map = require 'lodash/map'
_filter = require 'lodash/filter'
_take = require 'lodash/take'
_isEmpty = require 'lodash/isEmpty'
_orderBy = require 'lodash/orderBy'
_clone = require 'lodash/clone'
Environment = require 'clay-environment'
RxObservable = require('rxjs/Observable').Observable
require 'rxjs/add/observable/combineLatest'
require 'rxjs/add/operator/map'

Icon = require '../icon'
FlatButton = require '../flat_button'
AdsenseAd = require '../adsense_ad'
ClanBadge = require '../clan_badge'
GroupBadge = require '../group_badge'
Drawer = require '../drawer'
SemverService = require '../../services/semver'
Ripple = require '../ripple'
colors = require '../../colors'
config = require '../../config'

if window?
  IScroll = require 'iscroll/build/iscroll-lite-snap.js'
  require './index.styl'

GROUPS_IN_DRAWER = 2

module.exports = class NavDrawer
  constructor: ({@model, @router, group, @overlay$}) ->
    @$adsenseAd = new AdsenseAd {@model}
    @$groupBadge = new GroupBadge {@model, group}
    @$socialIcon = new Icon()
    @$drawer = new Drawer {
      @model
      isOpen: @model.drawer.isOpen()
      onOpen: @model.drawer.open
      onClose: @model.drawer.close
    }

    me = @model.user.getMe()
    meAndGroupAndLanguage = RxObservable.combineLatest(
      me
      group
      @model.l.getLanguage()
      (vals...) -> vals
    )

    myGroups = me.switchMap (me) =>
      @model.group.getAllByUserId me.id
    groupAndMyGroups = RxObservable.combineLatest(
      group
      myGroups
      me
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
      expandedItems: []
      group: group
      myGroups: groupAndMyGroups.map (props) =>
        [group, groups, me] = props
        groups = _orderBy groups, (group) =>
          @model.cookie.get("group_#{group.id}_lastVisit") or 0
        , 'desc'
        groups = _filter groups, ({id}) ->
          id isnt group.id
        groups = _take(groups, GROUPS_IN_DRAWER)
        _map groups, (group, i) =>
          meGroupUser = group.meGroupUser
          {
            group
            $badge: if group.clan \
                    then new ClanBadge {@model, clan: group.clan}
                    else new GroupBadge {@model, group}
            $chevronIcon: new Icon()
            $ripple: new Ripple()
          }
      windowSize: @model.window.getSize()
      drawerWidth: @model.window.getDrawerWidth()
      breakpoint: @model.window.getBreakpoint()

      menuItems: meAndGroupAndLanguage.map ([me, group, language]) =>
        groupId = group.key or group.id
        meGroupUser = group.meGroupUser
        _filter([
          {
            path: @router.get 'groupHome', {groupId}
            title: @model.l.get 'general.home'
            $icon: new Icon()
            $ripple: new Ripple()
            iconName: 'home'
            isDefault: true
          }
          {
            path: @router.get 'groupChat', {groupId}
            title: @model.l.get 'general.chat'
            $icon: new Icon()
            $ripple: new Ripple()
            iconName: 'chat'
          }
          {
            path: @router.get 'conversations'
            title: @model.l.get 'drawer.menuItemPrivateMessages'
            $icon: new Icon()
            $ripple: new Ripple()
            iconName: 'chat-bubble'
          }
          if group.key in [
            'clashroyalees', 'clashroyalept', 'clashroyalepl'
          ]
            {
              path: @router.get 'groupForum', {groupId}
              title: @model.l.get 'general.forum'
              $icon: new Icon()
              $ripple: new Ripple()
              iconName: 'rss'
            }
          if group.type is 'public'
            {
              path: @router.get 'groupShop', {groupId}
              # title: @model.l.get 'general.shop'
              title: @model.l.get 'general.freeStuff'
              $icon: new Icon()
              iconName: 'shop'
            }
          if group.type is 'public'
            {
              path: @router.get 'groupCollection', {groupId}
              title: @model.l.get 'collectionPage.title'
              $icon: new Icon()
              iconName: 'cards'
            }
          if group.key in ['playhard', 'eclihpse']
            {
              path: @router.get 'groupVideos', {groupId}
              title: @model.l.get 'videosPage.title'
              $icon: new Icon()
              iconName: 'video'
            }
          {
            path: @router.get 'groupLeaderboard', {groupId}
            title: @model.l.get 'groupLeaderboardPage.title'
            $icon: new Icon()
            iconName: 'trophy'
          }
          {
            path: @router.get 'groupProfile', {groupId}
            title: @model.l.get 'drawer.menuItemProfile'
            $icon: new Icon()
            $ripple: new Ripple()
            iconName: 'profile'
          }
          {
            path: @router.get 'groupTools', {groupId}
            title: @model.l.get 'addonsPage.title'
            $icon: new Icon()
            $ripple: new Ripple()
            iconName: 'ellipsis'
          }
          if @model.groupUser.hasPermission {
            meGroupUser, me, permissions: ['manageRole']
          }
            {
              path: @router.get 'groupSettings', {groupId}
              title: @model.l.get 'groupSettingsPage.title'
              $icon: new Icon()
              iconName: 'settings'
              $chevronIcon: new Icon()
              children: _filter [
                {
                  path: @router.get 'groupManageChannels', {groupId}
                  title: @model.l.get 'groupManageChannelsPage.title'
                }
                {
                  path: @router.get 'groupManageRoles', {groupId}
                  title: @model.l.get 'groupManageRolesPage.title'
                }
                if @model.groupUser.hasPermission {
                  meGroupUser, me, permissions: ['readAuditLog']
                }
                  {
                    path: @router.get 'groupAuditLog', {groupId}
                    title: @model.l.get 'groupAuditLogPage.title'
                  }
                {
                  path: @router.get 'groupBannedUsers', {groupId}
                  title: @model.l.get 'groupBannedUsersPage.title'
                }
                if me?.username in ['austin', 'brunoph']
                  {
                    path: @router.get 'groupSendNotification', {groupId}
                    title: @model.l.get 'groupSendNotificationPage.title'
                  }
              ]
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
          ])

  isExpandedByPath: (path) =>
    {expandedItems} = @state.getValue()
    expandedItems.indexOf(path) isnt -1

  toggleExpandItemByPath: (path) =>
    {expandedItems} = @state.getValue()
    isExpanded = @isExpandedByPath path

    if isExpanded
      expandedItems = _clone expandedItems
      expandedItems.splice expandedItems.indexOf(path), 1
      @state.set expandedItems: expandedItems
    else
      @state.set expandedItems: expandedItems.concat [path]

  render: ({currentPath}) =>
    {isOpen, me, menuItems, myGroups, drawerWidth, breakpoint, group,
      language, windowSize} = @state.getValue()

    group ?= {}
    groupId = group.key or group.id

    translateX = if isOpen then 0 else "-#{drawerWidth}px"
    # adblock plus blocks has-ad
    hasA = not Environment.isMobile() and windowSize?.height > 880

    renderChild = ({path, title, $chevronIcon, children}, depth = 0) =>
      isSelected = currentPath?.indexOf(path) is 0
      isExpanded = isSelected or @isExpandedByPath path

      hasChildren = not _isEmpty children
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
          if hasChildren
            z '.chevron',
              z $chevronIcon,
                icon: if isExpanded \
                      then 'chevron-up'
                      else 'chevron-down'
                color: colors.$tertiary500Text70
                isAlignedRight: true
                onclick: (e) =>
                  e?.stopPropagation()
                  e?.preventDefault()
                  @toggleExpandItemByPath path
        if hasChildren and isExpanded
          z "ul.children-#{depth}",
            _map children, (child) ->
              renderChild child, depth + 1

    z '.z-nav-drawer',
      z @$drawer,
        $content:
          z '.z-nav-drawer_drawer', {
            className: z.classKebab {hasA}
          },
            z '.header',
              z '.icon',
                z @$groupBadge
              z '.name',
                @model.group.getDisplayName group
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
                      z 'li.divider'
                    ]
                  _map menuItems, (menuItem) =>
                    {path, onclick, title, $icon, $chevronIcon, $ripple, isNew,
                      iconName, isDivider, children} = menuItem

                    hasChildren = not _isEmpty children
                    groupId = group.key or group.id

                    if isDivider
                      return z 'li.divider'

                    if menuItem.isDefault
                      isSelected = currentPath in [
                        @router.get 'siteHome'
                        @router.get 'groupHome', {groupId}
                        '/'
                      ]
                    else
                      isSelected = currentPath?.indexOf(path) is 0

                    isExpanded = isSelected or @isExpandedByPath path

                    z 'li.menu-item', {
                      className: z.classKebab {isSelected}
                    },
                      z 'a.menu-item-link', {
                        href: path
                        onclick: (e) =>
                          e.preventDefault()
                          if onclick
                            onclick()
                          else if path
                            @router.goPath path
                          @model.drawer.close()
                      },
                        z '.icon',
                          z $icon,
                            isTouchTarget: false
                            icon: iconName
                            color: colors.$primary500
                        title
                        if isNew
                          z '.new', @model.l.get 'general.new'
                        if hasChildren
                          z '.chevron',
                            z $chevronIcon,
                              icon: if isExpanded \
                                    then 'chevron-up'
                                    else 'chevron-down'
                              color: colors.$tertiary500Text70
                              isAlignedRight: true
                              touchHeight: '28px'
                              onclick: (e) =>
                                e?.stopPropagation()
                                e?.preventDefault()
                                @toggleExpandItemByPath path
                        if breakpoint is 'desktop'
                          z $ripple
                      if hasChildren and isExpanded
                        z 'ul.children',
                          _map children, (child) ->
                            renderChild child, 1

                  unless _isEmpty myGroups
                    z 'li.divider'

                  z 'li.subhead', @model.l.get 'drawer.otherGroups'

                  _map myGroups, (myGroup) =>
                    {$badge, $ripple, $chevronIcon, children} = myGroup
                    groupPath = @router.get 'groupHome', {
                      groupId: myGroup.group.key or myGroup.group.id
                    }
                    groupEnPath = @router.get 'groupHome', {
                      groupId: myGroup.group.key or myGroup.group.id
                      }, {language: 'en'}

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
                          @router.go 'groupHome', {
                            groupId: myGroup.group.key or myGroup.group.id
                          }
                      },
                        z '.icon',
                          z $badge
                        @model.group.getDisplayName myGroup.group
                        if breakpoint is 'desktop'
                          $ripple

                  z 'li.menu-item', {
                    className: z.classKebab {isSelected: false}
                  },
                    z 'a.menu-item-link', {
                      href: @router.get 'groups'
                      onclick: (e) =>
                        e.preventDefault()
                        @model.drawer.close()
                        @router.go 'groups'
                    },
                      z '.icon',
                        z @$socialIcon,
                          icon: 'friends'
                          isTouchTarget: false
                          color: colors.$primary500
                      @model.l.get 'drawer.menuItemMoreGroups'
                ]

            if hasA
              z '.ad',
                z @$adsenseAd, {
                  slot: 'desktop336x280'
                }
