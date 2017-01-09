z = require 'zorium'

Head = require '../../components/head'
GetApp = require '../../components/get_app'

if window?
  require './index.styl'

module.exports = class GetAppPage
  hideDrawer: true
  isPublic: true

  constructor: ({model, requests, @router, serverData}) ->
    @$head = new Head({
      model
      requests
      serverData
      meta: {
        title: 'Get App'
        description: 'Get App'
      }
    })
    @$getApp = new GetApp {model, @router, serverData}

    @state = z.state
      windowSize: model.window.getSize()

  renderHead: => @$head

  render: =>
    {windowSize} = @state.getValue()

    z '.p-get-app', {
      style:
        height: "#{windowSize.height}px"
    },
      @$getApp
