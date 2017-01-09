z = require 'zorium'

Head = require '../../components/head'
AppBar = require '../../components/app_bar'
ButtonBack = require '../../components/button_back'
Privacy = require '../../components/privacy'
colors = require '../../colors'

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

    @state = z.state
      windowSize: model.window.getSize()

  renderHead: => @$head

  render: =>
    {windowSize} = @state.getValue()

    z '.p-privacy', {
      style:
        height: "#{windowSize.height}px"
    },
      z @$appBar, {
        title: 'Privacy'
        $topLeftButton: z @$backButton, {color: colors.$tertiary900}
      }
      @$privacy
