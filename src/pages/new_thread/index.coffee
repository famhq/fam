z = require 'zorium'
Rx = require 'rx-lite'
Button = require 'zorium-paper/button'

config = require '../../config'
colors = require '../../colors'
Head = require '../../components/head'
NewThread = require '../../components/new_thread'

if window?
  require './index.styl'

module.exports = class NewThreadPage
  constructor: ({model, requests, @router, serverData}) ->
    @$head = new Head({
      model
      requests
      serverData
      meta: {
        title: 'New Thread'
        description: 'New Thread'
      }
    })
    @$newThread = new NewThread {model, @router}

  renderHead: => @$head

  render: =>
    z '.p-new-thread', {
      style:
        height: "#{window?.innerHeight}px"
    },
      @$newThread
