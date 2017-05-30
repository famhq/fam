z = require 'zorium'
Rx = require 'rx-lite'

Head = require '../../components/head'
Social = require '../../components/social'
BottomBar = require '../../components/bottom_bar'

if window?
  require './index.styl'

module.exports = class SocialPage
  constructor: ({@model, requests, @router, serverData}) ->
    @$social = new Social {@model, @router}

    @$head = new Head({
      @model
      requests
      serverData
      meta: {
        title: @model.l.get 'general.social'
        description: @model.l.get 'general.social'
      }
    })
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
      @$social
      @$bottomBar
