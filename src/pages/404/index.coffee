z = require 'zorium'

config = require '../../config'
Head = require '../../components/head'

module.exports = class FourOhFourPage
  constructor: ({@model, serverData}) ->
    @$head = new Head({
      @model
      serverData
      meta:
        title: 'Starfire - 404'
        description: 'Page not found'
        canonical: "http://#{config.HOST}/404"
    })

  renderHead: => @$head

  render: =>
    z '.p-404',
      @model.l.get '404Page'
      z 'br'
      '(╯°□°)╯︵ ┻━┻'
