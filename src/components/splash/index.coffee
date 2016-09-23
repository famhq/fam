_ = require 'lodash'
z = require 'zorium'
log = require 'loga'

PrimaryButton = require '../primary_button'
FlatButton = require '../flat_button'

if window?
  require './index.styl'

module.exports = class Splash
  constructor: ({model, @router}) ->
    @$learnMoreButton = new PrimaryButton()
    @$signInButton = new FlatButton()

    @state = z.state
      username: model.user.getMe().map ({username}) -> username

  render: =>
    {username} = @state.getValue()

    z '.z-splash',
      z '.content',
        z '.logo'
      z '.actions',
        z '.button',
          z @$signInButton,
            text: 'Sign in'
        z '.button',
          z @$learnMoreButton,
            text: 'Learn more'
            onclick: =>
              @router.go '/learnMore'
