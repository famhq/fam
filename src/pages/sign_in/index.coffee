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

    @state = z.state
      windowSize: @model.window.getSize()

  renderHead: => @$head

  render: =>
    {windowSize} = @state.getValue()

    z '.p-sign-in', {
      style:
        height: "#{windowSize.height}px"
    },
      @$signIn
