z = require 'zorium'

Head = require '../../components/head'
AppBar = require '../../components/app_bar'
ButtonBack = require '../../components/button_back'
Privacy = require '../../components/privacy'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class PrivacyPage
  constructor: ({@model, requests, @router, serverData}) ->
    @$head = new Head({
      @model
      requests
      serverData
      meta: {
        title: @model.l.get 'privacyPage.title'
        description: @model.l.get 'privacyPage.title'
      }
    })
    @$appBar = new AppBar {@model}
    @$backButton = new ButtonBack {@model, @router}
    @$privacy = new Privacy {@model, @router}

    @state = z.state
      windowSize: @model.window.getSize()

  renderHead: => @$head

  render: =>
    {windowSize} = @state.getValue()

    z '.p-privacy', {
      style:
        height: "#{windowSize.height}px"
    },
      z @$appBar, {
        title: @model.l.get 'privacyPage.title'
        $topLeftButton: z @$backButton, {color: colors.$tertiary900}
      }
      @$privacy
