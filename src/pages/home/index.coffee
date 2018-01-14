z = require 'zorium'

Head = require '../../components/head'
Spinner = require '../../components/spinner'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class HomePage
  hideDrawer: true

  constructor: ({@model, @router, requests, serverData}) ->
    @$head = new Head({
      @model
      requests
      serverData
      meta:
        canonical: "https://#{config.HOST}"
    })
    @$spinner = new Spinner()

    @state = z.state
      me: @model.user.getMe()
      windowSize: @model.window.getSize()

  renderHead: => @$head

  render: =>
    {me, windowSize} = @state.getValue()

    z '.p-home', {
      style:
        height: "#{windowSize.height}px"
    },
      @$spinner
