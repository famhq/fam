z = require 'zorium'

PrimaryButton = require '../primary_button'
FlatButton = require '../flat_button'

if window?
  require './index.styl'

module.exports = class Splash
  constructor: ({@model, @router}) ->
    @$createAccountButton = new PrimaryButton()
    @$signInButton = new FlatButton()

    @state = z.state
      username: @model.user.getMe().map ({username}) -> username

  render: =>
    {username} = @state.getValue()

    z '.z-splash',
      z '.content',
        z '.logo'
      z '.actions',
        z '.button',
          z @$signInButton,
            text: 'Sign in'
            onclick: =>
              @router.go '/signIn'
        z '.button',
          z @$createAccountButton,
            text: 'Create account'
            onclick: =>
              @router.go '/join'
