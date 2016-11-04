z = require 'zorium'
Rx = require 'rx-lite'
Button = require 'zorium-paper/button'
_ = require 'lodash'

config = require '../../config'
colors = require '../../colors'
Head = require '../../components/head'
Pay = require '../../components/pay'

if window?
  require './index.styl'

module.exports = class PayPage
  hideDrawer: true
  isPublic: true

  constructor: ({model, requests, @router, serverData}) ->
    @$editButton = new Button()
    @$head = new Head({
      model
      requests
      serverData
      meta: {
        title: 'Pay'
        description: 'Pay'
      }
    })
    @$pay = new Pay {model, @router}

  renderHead: => @$head

  render: =>
    z '.p-pay', {
      style:
        height: "#{window?.innerHeight}px"
    },
      @$pay
