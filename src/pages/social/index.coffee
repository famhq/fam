z = require 'zorium'
Rx = require 'rx-lite'

Head = require '../../components/head'
AppBar = require '../../components/app_bar'
ButtonMenu = require '../../components/button_menu'
BottomBar = require '../../components/bottom_bar'
Social = require '../../components/social'
colors = require '../../colors'

if window?
  require './index.styl'

TABS = ['groups', 'conversations']

module.exports = class SocialPage
  constructor: ({@model, requests, @router, serverData}) ->
    @$head = new Head({
      @model
      requests
      serverData
      meta: {
        title: @model.l.get 'general.social'
        description: @model.l.get 'general.social'
      }
    })

    @$appBar = new AppBar {@model}
    @$buttonMenu = new ButtonMenu {@model}
    @$social = new Social {@model, @router}
    @$bottomBar = new BottomBar {@model, @router, requests}

    @state = z.state
      windowSize: @model.window.getSize()

  renderHead: => @$head

  render: =>
    {windowSize} = @state.getValue()

    z '.p-social', {
      style:
        height: "#{windowSize.height}px"
    },
      z @$appBar, {
        title: @model.l.get 'general.social'
        isFlat: true
        $topLeftButton: z @$buttonMenu, {color: colors.$primary500}
      }
      @$social
      @$bottomBar
