z = require 'zorium'

Head = require '../../components/head'
AppBar = require '../../components/app_bar'
ButtonMenu = require '../../components/button_menu'
Profile = require '../../components/profile'

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

    @state = z.state
      windowSize: model.window.getSize()

  renderHead: => @$head

  render: =>
    {windowSize} = @state.getValue()

    z '.p-profile', {
      style:
        height: "#{windowSize.height}px"
    },
      z @$appBar, {
        title: null
        $topLeftButton: @$buttonMenu
        isFlat: true
      }
      @$profile
