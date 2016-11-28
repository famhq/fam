z = require 'zorium'
Rx = require 'rx-lite'
Button = require 'zorium-paper/button'
_ = require 'lodash'

config = require '../../config'
colors = require '../../colors'
Head = require '../../components/head'
AppBar = require '../../components/app_bar'
ButtonMenu = require '../../components/button_menu'
Refer = require '../../components/refer'

if window?
  require './index.styl'

module.exports = class ReferPage
  constructor: ({model, requests, @router, serverData}) ->
    @$editButton = new Button()
    @$head = new Head({
      model
      requests
      serverData
      meta: {
        title: 'Refer'
        description: 'Refer'
      }
    })
    @$appBar = new AppBar {model}
    @$buttonMenu = new ButtonMenu {model}
    @$refer = new Refer {model, @router}

  renderHead: => @$head

  render: =>
    z '.p-refer', {
      style:
        height: "#{window?.innerHeight}px"
    },
      z @$appBar, {
        title: 'Refer a member'
        $topLeftButton: z @$buttonMenu, {color: colors.$tertiary900}
      }
      @$refer
