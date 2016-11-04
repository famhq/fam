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
  hideDrawer: true
  isPublic: true

  constructor: ({model, requests, @router, serverData}) ->
    code = requests.map ({route}) ->
      route.params.code

    user = code.flatMapLatest (code) ->
      model.user.getByCode code

    @$head = new Head({
      model
      requests
      serverData
      meta: {
        title: 'Accept Invite'
        description: 'Accept Invite'
      }
    })
    @$acceptInvite = new AcceptInvite {model, @router, code, user}

  renderHead: => @$head

  render: =>
    z '.p-accept-invite', {
      style:
        height: "#{window?.innerHeight}px"
    },
      @$acceptInvite
