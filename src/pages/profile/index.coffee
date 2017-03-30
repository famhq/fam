z = require 'zorium'
Rx = require 'rx-lite'

Head = require '../../components/head'
AppBar = require '../../components/app_bar'
ButtonMenu = require '../../components/button_menu'
ButtonBack = require '../../components/button_back'
Profile = require '../../components/profile'
ProfileLanding = require '../../components/profile_landing'
BottomBar = require '../../components/bottom_bar'
ShareSheet = require '../../components/share_sheet'
Spinner = require '../../components/spinner'
Icon = require '../../components/icon'
config = require '../../config'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class ProfilePage
  constructor: ({@model, requests, @router, serverData}) ->
    username = requests.map ({route}) ->
      if route.params.username then route.params.username else false

    id = requests.map ({route}) ->
      if route.params.id then route.params.id else false

    usernameAndId = Rx.Observable.combineLatest(
      username
      id
      (vals...) -> vals
    )

    user = usernameAndId.flatMapLatest ([username, id]) =>
      if username
        @model.user.getByUsername username
      else if id
        @model.user.getById id
      else
        @model.user.getMe()

    clashRoyaleData = user.flatMapLatest ({id}) =>
      @model.userGameData.getByUserIdAndGameId id, config.CLASH_ROYALE_ID
      .map (userGameData) ->
        return userGameData or {}

    @isShareSheetVisible = new Rx.BehaviorSubject false

    @$head = new Head({
      @model
      requests
      serverData
      meta: clashRoyaleData.map (clashRoyaleData) ->
        playerName = clashRoyaleData?.data?.name
        {
          title: if clashRoyaleData?.playerId \
                 then "#{playerName}'s Clash Royale stats - Starfire"
                 else 'Starfire - track wins, losses and more in Clash Royale'

          description: 'Automatically track useful Clash Royale stats to ' +
                        'become a better player!'
        }
    })
    @$appBar = new AppBar {@model}
    @$buttonMenu = new ButtonMenu {@model}
    @$buttonBack = new ButtonBack {@model, @router}
    @$profile = new Profile {@model, @router, user}
    @$profileLanding = new ProfileLanding {@model, @router}
    @$bottomBar = new BottomBar {@model, @router, requests}
    @$shareSheet = new ShareSheet {
      @router, @model, isVisible: @isShareSheetVisible
    }
    @$settingsIcon = new Icon()
    @$shareIcon = new Icon()
    @$spinner = new Spinner()

    @state = z.state
      windowSize: @model.window.getSize()
      username: username
      user: user
      id: id
      isShareSheetVisible: @isShareSheetVisible
      me: @model.user.getMe()
      clashRoyaleData: clashRoyaleData
      requests: requests

  renderHead: => @$head

  render: =>
    {windowSize, clashRoyaleData, me, username, id, user,
      isShareSheetVisible} = @state.getValue()

    isTagSet = clashRoyaleData?.playerId
    isMe = me?.id is user?.id or (not id and not username)
    playerName = clashRoyaleData?.data?.name

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

    z '.p-profile', {
      style:
        height: "#{windowSize.height}px"
    },
      z @$appBar, {
        title: if not isMe then clashRoyaleData?.data?.name else 'Profile'
        $topLeftButton: if not isMe then @$buttonBack else @$buttonMenu
        $topRightButton: z '.p-profile_top-right',
          if isTagSet
            z @$shareIcon,
              icon: 'share'
              onclick: =>
                @isShareSheetVisible.onNext true
          if isMe and isTagSet
            z @$settingsIcon, {
              icon: 'settings'
              color: colors.$tertiary900
              onclick: =>
                @router.go '/editProfile'
              }
        isFlat: isTagSet
      }
      if clashRoyaleData and isTagSet
        @$profile
      else if clashRoyaleData
        @$profileLanding
      else
        @$spinner

      @$bottomBar

      if isShareSheetVisible
        z @$shareSheet, {text, path}
