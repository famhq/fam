z = require 'zorium'
Rx = require 'rx-lite'
Button = require 'zorium-paper/button'

config = require '../../config'
colors = require '../../colors'
Head = require '../../components/head'
AppBar = require '../../components/app_bar'
ButtonMenu = require '../../components/button_menu'
Profile = require '../../components/profile'

if window?
  require './index.styl'

module.exports = class ProfilePage
  constructor: ({model, requests, @router, serverData}) ->
    @$editButton = new Button()
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

  renderHead: => @$head

  render: =>
    z '.p-profile', {
      style:
        height: "#{window?.innerHeight}px"
    },
      z @$appBar, {
        title: null
        $topLeftButton: @$buttonMenu
        isFlat: true
      }
      @$profile
