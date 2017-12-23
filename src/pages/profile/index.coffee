z = require 'zorium'
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject
RxObservable = require('rxjs/Observable').Observable
require 'rxjs/add/observable/combineLatest'

Head = require '../../components/head'
AppBar = require '../../components/app_bar'
ButtonMenu = require '../../components/button_menu'
ButtonBack = require '../../components/button_back'
Profile = require '../../components/profile'
ProfileInfo = require '../../components/profile_info'
ProfileLanding = require '../../components/clash_royale_profile_landing'
BottomBar = require '../../components/bottom_bar'
ShareSheet = require '../../components/share_sheet'
Spinner = require '../../components/spinner'
Icon = require '../../components/icon'
config = require '../../config'
colors = require '../../colors'

if window?
  require './index.styl'

PROFILE_INFO_HEIGHT_PX = 80

module.exports = class ProfilePage
  constructor: ({@model, requests, @router, serverData}) ->
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

    gameKey = requests. map ({route}) ->
      route.params.gameKey or config.DEFAULT_GAME_KEY

    player = routePlayerId.switchMap (playerId) =>
      if playerId
        @model.player.getByPlayerIdAndGameId(
          playerId, config.CLASH_ROYALE_ID, {refreshIfStale: true}
        )
      else
        user.switchMap ({id}) =>
          @model.player.getByUserIdAndGameId id, config.CLASH_ROYALE_ID
          .map (player) ->
            return player or {}

    @hideDrawer = usernameAndId.map ([username, id]) ->
      username or id

    @isShareSheetVisible = new RxBehaviorSubject false
    @overlay$ = new RxBehaviorSubject null

    @$head = new Head({
      @model
      requests
      serverData
      meta: player.map (player) ->
        playerName = player?.data?.name
        {
          title: if player?.id \
                 then "#{playerName}'s Clash Royale stats"
                 else undefined # use default

          description: undefined # use default
        }
    })
    @$appBar = new AppBar {@model}
    @$buttonMenu = new ButtonMenu {@model}
    @$buttonBack = new ButtonBack {@model, @router}
    @$profile = new Profile {
      @model, @router, user, player, @overlay$, gameKey, serverData
    }
    @$profileInfo = new ProfileInfo {@model, @router, gameKey, user}
    @$profileLanding = new ProfileLanding {@model, @router, gameKey}
    @$bottomBar = new BottomBar {@model, @router, requests}
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
      isShareSheetVisible: @isShareSheetVisible
      me: me
      gameKey: gameKey
      player: player
      requests: requests
      overlay$: @overlay$

  afterMount: (@$$el) =>
    @$$content = @$$el.querySelector('.content')

  renderHead: => @$head

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
      isShareSheetVisible, overlay$, gameKey} = @state.getValue()

    isTagSet = player?.id
    isOtherProfile = routeId or routeUsername or routePlayerId
    isMe = me?.id is user?.id or not user
    playerName = player?.data?.name

    if isMe
      text = 'View my Clash Royale profile on Starfire'
      username = me?.username
      id = me?.id
    else
      text = "#{playerName}'s Clash Royale stats Clash Royale
              profile on Starfire"
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
        bgColor: if player and not isTagSet \
                 then colors.$primary500
                 else colors.$tertiary700
        $topLeftButton:
          z $button,
            color: if player and not isTagSet \
                   then colors.$tertiary900
                   else colors.$primary500
        $topRightButton: z '.p-profile_top-right',
          if isTagSet
            z @$shareIcon,
              icon: 'share'
              color: colors.$primary500
              onclick: =>
                @isShareSheetVisible.next true
          if isMe and isTagSet
            z @$settingsIcon, {
              icon: 'settings'
              color: colors.$primary500
              onclick: =>
                @router.go 'editProfile', {gameKey}
              }
        isFlat: true
      }
      z '.content',
        if (user?.isMember or (player and isTagSet)) and not routePlayerId
          z '.profile-info', {
            style:
              height: "#{PROFILE_INFO_HEIGHT_PX}px"
          },
            z @$profileInfo
        if player and isTagSet
          z '.profile', {
            ontouchmove: @scrollPastInfo
            ontouchend: =>
              @prevClientY = null
          },
            z @$profile, {isOtherProfile}
        else if player
          z @$profileLanding, {isHome: not routeId}
        else
          @$spinner

      unless isOtherProfile
        @$bottomBar

      if isShareSheetVisible
        z @$shareSheet, {text, path}

      if overlay$
        overlay$
