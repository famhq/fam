z = require 'zorium'

Head = require '../../components/head'
SetAddress = require '../../components/set_address'

if window?
  require './index.styl'

module.exports = class SetAddressPage
  hideDrawer: true

  constructor: ({model, requests, @router, serverData}) ->
    @$head = new Head({
      model
      requests
      serverData
      meta: {
        title: 'Set Address'
        description: 'Set Address'
      }
    })
    @$setAddress = new SetAddress {model, @router}

    @state = z.state
      windowSize: model.window.getSize()

  renderHead: => @$head

  render: =>
    {windowSize} = @state.getValue()

    z '.p-set-address', {
      style:
        height: "#{windowSize.height}px"
    },
      @$setAddress
