z = require 'zorium'

Head = require '../../components/head'
AppBar = require '../../components/app_bar'
ButtonMenu = require '../../components/button_menu'
Profile = require '../../components/profile'
ProfileLanding = require '../../components/profile_landing'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class ProfilePage
  constructor: ({model, requests, @router, serverData}) ->
    @$head = new Head({
      model
      requests
      serverData
      meta: {
        title: 'Profile'
        description: 'Profile'
      }
    })
    @$appBar = new AppBar {model}
    @$buttonMenu = new ButtonMenu {model}
    @$profile = new Profile {model, @router}
    @$profileLanding = new ProfileLanding {model, @router}

    @state = z.state
      windowSize: model.window.getSize()
      clashRoyaleData: model.userGameData.getMeByGameId config.CLASH_ROYALE_ID

  renderHead: => @$head

  render: =>
    {windowSize, clashRoyaleData} = @state.getValue()

    isTagSet = clashRoyaleData?.playerId

    z '.p-profile', {
      style:
        height: "#{windowSize.height}px"
    },
      z @$appBar, {
        title: 'Profile'
        $topLeftButton: @$buttonMenu
        isFlat: isTagSet
      }
      if isTagSet
        @$profile
      else
        @$profileLanding
