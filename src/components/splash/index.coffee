_ = require 'lodash'
z = require 'zorium'
log = require 'loga'

PrimaryButton = require '../primary_button'
FlatButton = require '../flat_button'

if window?
  require './index.styl'

module.exports = class Splash
  constructor: ({@model, @router}) ->
    @$learnMoreButton = new PrimaryButton()
    @$signInButton = new FlatButton()

    @state = z.state
      username: @model.user.getMe().map ({username}) -> username

  render: =>
    {username} = @state.getValue()

    z '.z-splash',
      z '.content',
        z '.logo'
      z '.actions',
        # @router?.link z 'a.description', {
        #   href: '/tos'
        # },
        #   'By continuing, you agree to our '
        #   z 'strong', 'T.O.S.'

        z '.button',
          z @$signInButton,
            text: 'Sign in'
            onclick: =>
              @router.go '/signIn'
        z '.button',
          z @$learnMoreButton,
            text: 'Learn more'
            onclick: =>
              @router.go '/learnMore'
