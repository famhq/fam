z = require 'zorium'
Rx = require 'rx-lite'
Button = require 'zorium-paper/button'
_ = require 'lodash'

config = require '../../config'
colors = require '../../colors'
Head = require '../../components/head'
SignIn = require '../../components/sign_in'

if window?
  require './index.styl'

module.exports = class SignInPage
  hideDrawer: true
  isPublic: true

  constructor: ({model, requests, @router, serverData}) ->
    @$head = new Head({
      model
      requests
      serverData
      meta: {
        title: 'Sign In'
        description: 'Sign In'
      }
    })
    @$signIn = new SignIn {model, @router}

  renderHead: => @$head

  render: =>
    z '.p-sign-in', {
      style:
        height: "#{window?.innerHeight}px"
    },
      @$signIn
