z = require 'zorium'

Head = require '../../components/head'
AppBar = require '../../components/app_bar'
ButtonBack = require '../../components/button_back'
Tos = require '../../components/tos'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class TosPage
  isPublic: true

  constructor: ({model, requests, @router, serverData}) ->
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
