z = require 'zorium'
Rx = require 'rx-lite'
Button = require 'zorium-paper/button'
_ = require 'lodash'

config = require '../../config'
colors = require '../../colors'
Head = require '../../components/head'
AppBar = require '../../components/app_bar'
ButtonBack = require '../../components/button_back'
Privacy = require '../../components/privacy'

if window?
  require './index.styl'

module.exports = class PrivacyPage
  isPublic: true

  constructor: ({model, requests, @router, serverData}) ->
    @$editButton = new Button()
    @$head = new Head({
      model
      requests
      serverData
      meta: {
        title: 'Privacy'
        description: 'Privacy'
      }
    })
    @$appBar = new AppBar {model}
    @$backButton = new ButtonBack {model, @router}
    @$privacy = new Privacy {model, @router}

  renderHead: => @$head

  render: =>
    z '.p-privacy', {
      style:
        height: "#{window?.innerHeight}px"
    },
      z @$appBar, {
        title: 'Privacy'
        $topLeftButton: z @$backButton, {color: colors.$primary900}
      }
      @$privacy
