z = require 'zorium'
_startCase = require 'lodash/startCase'
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject
RxObservable = require('rxjs/Observable').Observable
require 'rxjs/add/observable/combineLatest'

AppBar = require '../../components/app_bar'
ButtonMenu = require '../../components/button_menu'
ButtonBack = require '../../components/button_back'
ProfileInfo = require '../../components/profile_info'
ClashRoyaleProfile = require '../../components/clash_royale_profile'
ClashRoyaleGetPlayerTagForm =
  require '../../components/clash_royale_get_player_tag_form'
FortniteGetPlayerTagForm =
  require '../../components/fortnite_get_player_tag_form'
GroupHomeFortniteStats = require '../../components/group_home_fortnite_stats'
ShareSheet = require '../../components/share_sheet'
Spinner = require '../../components/spinner'
Icon = require '../../components/icon'
config = require '../../config'
colors = require '../../colors'

if window?
  require './index.styl'

PROFILE_INFO_HEIGHT_PX = 96

module.exports = class GroupProfilePage
  isGroup: true
  @hasBottomBar: true
  constructor: ({@model, requests, @router, serverData, group, @$bottomBar}) ->
    username = requests.map ({route}) ->
      if route.params.username then route.params.username else false

    id = requests.map ({route}) ->
      if route.params.id then route.params.id else false

    usernameAndId = RxObservable.combineLatest(
      username
      id
      (vals...) -> vals
    )

    me = @model.user.getMe()
    user = usernameAndId.switchMap ([username, id]) =>
      if username
        @model.user.getByUsername username
      else if id
        @model.user.getById id
      else
        @model.user.getMe()

    routePlayerId = requests. map ({route}) ->
      if route.params.playerId then route.params.playerId else false

    routePlayerIdAndGroup = RxObservable.combineLatest(
      routePlayerId, group, (vals...) -> vals
    )

    @player = routePlayerIdAndGroup.switchMap ([playerId, group]) =>
      gameKey = group.gameKeys?[0] or 'clash-royale'
      if playerId
        @model.player.getByPlayerIdAndGameKey(
          playerId, gameKey, {refreshIfStale: true}
        )
      else
        user.switchMap ({id}) =>
          @model.player.getByUserIdAndGameKey id, gameKey
          .map (player) ->
            return player or {}

    @hideDrawer = usernameAndId.map ([username, id]) ->
      username or id

    @isShareSheetVisible = new RxBehaviorSubject false
    @overlay$ = new RxBehaviorSubject null

    @$appBar = new AppBar {@model}
    @$buttonMenu = new ButtonMenu {@model}
    @$buttonBack = new ButtonBack {@model, @router}
    @$clashRoyaleProfile = new ClashRoyaleProfile {
      @model, @router, user, @player, @overlay$, group, serverData
    }
    @$clashRoyaleProfileInfo = new ProfileInfo {@model, @router, group, user}
    @$groupHomeFortniteStats = new GroupHomeFortniteStats {
      @model, @router, group, @player
    }
    # @$clashRoyaleProfileLanding = new ProfileLanding {@model, @router, group}
    @$clashRoyaleGetPlayerTagForm = new ClashRoyaleGetPlayerTagForm {
      @model, @router
    }
    @$fortniteGetPlayerTagForm = new FortniteGetPlayerTagForm {@model, @router}
    @$shareSheet = new ShareSheet {
      @router, @model, isVisible: @isShareSheetVisible
    }
    @$settingsIcon = new Icon()
    @$shareIcon = new Icon()
    @$spinner = new Spinner()

    @state = z.state
      windowSize: @model.window.getSize()
      routeUsername: username
      user: user
      routeId: id
      routePlayerId: routePlayerId
      group: group
      isShareSheetVisible: @isShareSheetVisible
      me: me
      player: @player
      requests: requests
      overlay$: @overlay$

  afterMount: (@$$el) =>
    @$$content = @$$el.querySelector('.content')

  getMeta: =>
    {player} = @state.getValue()
    @player.map (player) ->
      playerName = player?.data?.name
      {
        title: if player?.id \
               then "#{playerName}'s Clash Royale stats"
               else undefined # use default

        description: undefined # use default
      }

  scrollPastInfo: (e) =>
    clientY = e?.touches?[0]?.clientY
    isScrollDown = @prevClientY? and @prevClientY - clientY > 0
    @prevClientY = clientY
    if not @isScrolling and isScrollDown and
        @$$content.scrollTop < PROFILE_INFO_HEIGHT_PX
      @isScrolling = true

      prevTime = Date.now()
      update = =>
        dt = Date.now() - prevTime
        newScrollTop = @$$content.scrollTop +
                        PROFILE_INFO_HEIGHT_PX * (dt / 1000)
        if newScrollTop >= PROFILE_INFO_HEIGHT_PX
          @$$content.scrollTop = newScrollTop = PROFILE_INFO_HEIGHT_PX
          @isScrolling = false
        else
          @$$content.scrollTop = newScrollTop
          window.requestAnimationFrame update
      update()

  render: =>
    {windowSize, player, me, routeUsername, routeId, routePlayerId, user,
      isShareSheetVisible, overlay$, group} = @state.getValue()

    isTagSet = player?.id
    isOtherProfile = routeId or routeUsername or routePlayerId
    isMe = me?.id is user?.id or not user
    playerName = player?.data?.name
    gameKey = group?.gameKeys?[0]

    if isMe
      text = "View my #{_startCase(gameKey)} profile on Fam"
      username = me?.username
      id = me?.id
    else
      text = "#{playerName}'s #{_startCase(gameKey)} profile on Fam"
      username = user?.username
      id = user?.id

    path = if username then "/user/#{username}" else "/user/id/#{id}"

    $button = if isOtherProfile then @$buttonBack else @$buttonMenu


    z '.p-profile', {
      style:
        height: "#{windowSize.height}px"
    },
      z @$appBar, {
        title: null
              #  if not isMe \
              #  then player?.data?.name
              #  else if player?.id
              #  then @model.l.get 'profilePage.title'
              #  else ''
        $topLeftButton:
          z $button,
            color: colors.$header500Icon
        $topRightButton: z '.p-profile_top-right',
          if isTagSet
            z @$shareIcon,
              icon: 'share'
              color: colors.$header500Icon
              onclick: =>
                @isShareSheetVisible.next true
          if isMe and isTagSet
            z @$settingsIcon, {
              icon: 'settings'
              color: colors.$header500Icon
              onclick: =>
                @router.go 'editProfile', {groupId: group.key or group.id}
              }
        isFlat: true
      }
      z '.content',
        if (user?.isMember or (player and isTagSet)) and not routePlayerId
          z '.profile-info', {
            style:
              height: "#{PROFILE_INFO_HEIGHT_PX}px"
          },
            z @$clashRoyaleProfileInfo
        if player and isTagSet
          z '.profile', {
            ontouchmove: @scrollPastInfo
            ontouchend: =>
              @prevClientY = null
          },
            if gameKey is 'fortnite'
              z '.g-grid',
                z @$groupHomeFortniteStats
            else
              z @$clashRoyaleProfile, {isOtherProfile}
        else if player and isMe
          if gameKey is 'fortnite'
            z '.get-tag',
              z @$fortniteGetPlayerTagForm
          else
            z '.get-tag',
              z @$clashRoyaleGetPlayerTagForm
        else if not player
          @$spinner

      unless isOtherProfile
        @$bottomBar

      if isShareSheetVisible
        z @$shareSheet, {text, path}

      if overlay$
        overlay$
