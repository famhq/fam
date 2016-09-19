z = require 'zorium'

config = require '../../config'
Head = require '../../components/head'
HelloWorld = require '../../components/hello_world'

module.exports = class HomePage
  constructor: ({model, router, serverData}) ->
    @$head = new Head({
      model
      serverData
      meta:
        canonical: "https://#{config.HOST}"
    })
    @$hello = new HelloWorld({model, router})

  renderHead: => @$head

  render: =>
    z '.p-home',
      @$hello
