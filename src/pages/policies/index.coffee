z = require 'zorium'
Rx = require 'rx-lite'
Button = require 'zorium-paper/button'

config = require '../../config'
colors = require '../../colors'
Head = require '../../components/head'
Policies = require '../../components/policies'

if window?
  require './index.styl'

module.exports = class PoliciesPage
  hideDrawer: true
  isPublic: true

  constructor: ({model, requests, @router, serverData}) ->
    @$editButton = new Button()
    @$head = new Head({
      model
      requests
      serverData
      meta: {
        title: 'Policies'
        description: 'Policies'
      }
    })
    @$policies = new Policies {model, @router}

  renderHead: => @$head

  render: =>
    z '.p-policies', {
      style:
        height: "#{window?.innerHeight}px"
    },
      @$policies
