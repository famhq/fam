z = require 'zorium'

config = require '../../config'
Head = require '../../components/head'
Splash = require '../../components/splash'

if window?
  require './index.styl'

module.exports = class HomePage
  constructor: ({model, router, serverData}) ->
    @$head = new Head({
      model
      serverData
      meta:
        canonical: "https://#{config.HOST}"
    })
    @$splash = new Splash({model, router})

  renderHead: => @$head

  render: =>
    z '.p-home', {
      style:
        height: "#{window?.innerHeight}px"
    },
      @$splash
