z = require 'zorium'
Rx = require 'rx-lite'

Head = require '../../components/head'
AppBar = require '../../components/app_bar'
ButtonMenu = require '../../components/button_menu'
Profile = require '../../components/profile'
ProfileLanding = require '../../components/profile_landing'
BottomBar = require '../../components/bottom_bar'
Spinner = require '../../components/spinner'
Icon = require '../../components/icon'
config = require '../../config'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class ProfilePage
  constructor: ({model, requests, @router, serverData}) ->
    userId = requests.map ({route}) ->
      if route.params.id then route.params.id else false

    user = userId.flatMapLatest (userId) ->
      if userId
        model.user.getById userId
      else
        model.user.getMe()

    @$head = new Head({
      model
      requests
      serverData
      meta: {
        title: 'Starfire - track wins, losses and more in Clash Royale'
        description: 'Automatically track useful Clash Royale stats to become' +
                      ' a better player!'
      }
    })
    @$appBar = new AppBar {model}
    @$buttonMenu = new ButtonMenu {model}
    @$profile = new Profile {model, @router, user}
    @$profileLanding = new ProfileLanding {model, @router}
    @$bottomBar = new BottomBar {model, @router, requests}
    @$settingsIcon = new Icon()
    @$spinner = new Spinner()

    @state = z.state
      windowSize: model.window.getSize()
      userId: userId
      me: model.user.getMe()
      clashRoyaleData: user.flatMapLatest ({id}) ->
        model.userGameData.getByUserIdAndGameId id, config.CLASH_ROYALE_ID
        .map (userGameData) ->
          return userGameData or {}
      requests: requests

  renderHead: => @$head

  render: =>
    {windowSize, clashRoyaleData, me, userId} = @state.getValue()

    isTagSet = clashRoyaleData?.playerId
    isMe = isTagSet and ((me?.id is userId) or not userId)

    z '.p-profile', {
      style:
        height: "#{windowSize.height}px"
    },
      z @$appBar, {
        title: 'Profile'
        $topLeftButton: @$buttonMenu
        $topRightButton: if isMe \
                         then z @$settingsIcon, {
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
