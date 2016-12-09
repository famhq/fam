z = require 'zorium'
Rx = require 'rx-lite'
Button = require 'zorium-paper/button'
_ = require 'lodash'

config = require '../../config'
colors = require '../../colors'
Head = require '../../components/head'
Join = require '../../components/join'

if window?
  require './index.styl'

module.exports = class JoinPage
  hideDrawer: true
  isPublic: true

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

  renderHead: => @$head

  render: =>
    z '.p-sign-in', {
      style:
        height: "#{window?.innerHeight}px"
    },
      @$join
