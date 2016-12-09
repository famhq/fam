z = require 'zorium'
Rx = require 'rx-lite'
Button = require 'zorium-paper/button'

config = require '../../config'
colors = require '../../colors'
Head = require '../../components/head'
AppBar = require '../../components/app_bar'
ButtonBack = require '../../components/button_back'
Tos = require '../../components/tos'

if window?
  require './index.styl'

module.exports = class TosPage
  isPublic: true

  constructor: ({model, requests, @router, serverData}) ->
    @$editButton = new Button()
    @$head = new Head({
      model
      requests
      serverData
      meta: {
        title: 'Terms of Service'
        description: 'Terms of Service'
      }
    })
    @$appBar = new AppBar {model}
    @$backButton = new ButtonBack {model, @router}
    @$tos = new Tos {model, @router}

  renderHead: => @$head

  render: =>
    z '.p-tos', {
      style:
        height: "#{window?.innerHeight}px"
    },
      z @$appBar, {
        title: 'Terms of Service'
        $topLeftButton: z @$backButton, {color: colors.$tertiary900}
      }
      @$tos
