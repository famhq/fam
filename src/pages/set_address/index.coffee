z = require 'zorium'
Rx = require 'rx-lite'
Button = require 'zorium-paper/button'

config = require '../../config'
colors = require '../../colors'
Head = require '../../components/head'
SetAddress = require '../../components/set_address'

if window?
  require './index.styl'

module.exports = class SetAddressPage
  hideDrawer: true
  isPublic: true

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

  renderHead: => @$head

  render: =>
    z '.p-set-address', {
      style:
        height: "#{window?.innerHeight}px"
    },
      @$setAddress
