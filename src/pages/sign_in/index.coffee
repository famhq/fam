z = require 'zorium'

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
