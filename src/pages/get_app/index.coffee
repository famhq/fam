z = require 'zorium'
Rx = require 'rx-lite'
Button = require 'zorium-paper/button'

config = require '../../config'
colors = require '../../colors'
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

  renderHead: => @$head

  render: =>
    z '.p-get-app', {
      style:
        height: "#{window?.innerHeight}px"
    },
      @$getApp
