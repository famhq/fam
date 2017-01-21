z = require 'zorium'

Head = require '../../components/head'
Join = require '../../components/join'

if window?
  require './index.styl'

module.exports = class JoinPage
  hideDrawer: true

  constructor: ({model, requests, @router, serverData}) ->
    @$head = new Head({
      model
      requests
      serverData
      meta: {
        title: 'Join'
        description: 'Join'
      }
    })
    @$join = new Join {model, @router}

    @state = z.state
      windowSize: model.window.getSize()

  renderHead: => @$head

  render: =>
    {windowSize} = @state.getValue()

    z '.p-join', {
      style:
        height: "#{windowSize.height}px"
    },
      @$join
