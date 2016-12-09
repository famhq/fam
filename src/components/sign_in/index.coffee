z = require 'zorium'
log = require 'loga'
Rx = require 'rx-lite'

PrimaryInput = require '../primary_input'
PrimaryButton = require '../primary_button'
FlatButton = require '../flat_button'
InfoBlock = require '../info_block'
Form = require '../form'

if window?
  require './index.styl'

module.exports = class SignIn
  constructor: ({@model, @router}) ->
    @$joinButton = new FlatButton()
    @$signInButton = new PrimaryButton()

    @usernameValue = new Rx.BehaviorSubject ''
    @passwordValue = new Rx.BehaviorSubject ''
    @usernameError = new Rx.BehaviorSubject null
    @passwordError = new Rx.BehaviorSubject null
    @$usernameInput = new PrimaryInput
      value: @usernameValue
      error: @usernameError
    @$passwordInput = new PrimaryInput
      value: @passwordValue
      error: @passwordError

    @$infoBlock = new InfoBlock()
    @$form = new Form()

    @state = z.state
      isLoading: false

  login: (e) =>
    e?.preventDefault()

    @state.set isLoading: true
    @model.auth.login {
      username: @usernameValue.getValue()
      password: @passwordValue.getValue()
    }
    .then =>
      @state.set isLoading: false
      @router.go '/community'
    .catch (err) =>
      @usernameError.onNext err.message
      @state.set isLoading: false

  render: =>
    {isLoading} = @state.getValue()

    z '.z-sign-in',
      z @$infoBlock,
        $title: 'Welcome back!'
        $form: z @$form,
          onsubmit: @login
          $inputs: [
            z @$usernameInput,
              hintText: 'Username'

            z @$passwordInput,
              type: 'password'
              hintText: 'Password'
          ]
          $buttons: [
            z @$signInButton,
              text: if isLoading then 'Loading...' else 'Sign in'
              type: 'submit'

            z @$joinButton,
              text: 'Create account'
              onclick: =>
                @router.go '/join'

          ]
