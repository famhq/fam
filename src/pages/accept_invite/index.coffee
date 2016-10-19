z = require 'zorium'
Rx = require 'rx-lite'
Button = require 'zorium-paper/button'
_ = require 'lodash'

config = require '../../config'
colors = require '../../colors'
Head = require '../../components/head'
AcceptInvite = require '../../components/accept_invite'

if window?
  require './index.styl'

module.exports = class AcceptInvitePage
  constructor: ({model, requests, @router, serverData}) ->
    @$editButton = new Button()
    @$head = new Head({
      model
      requests
      serverData
      meta: {
        title: 'Accept Invite'
        description: 'Accept Invite'
      }
    })
    @$acceptInvite = new AcceptInvite {model, @router}

  renderHead: => @$head

  render: =>
    z '.p-accept-invite', {
      style:
        height: "#{window?.innerHeight}px"
    },
      @$acceptInvite
