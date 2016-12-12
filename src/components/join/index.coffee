z = require 'zorium'
Rx = require 'rx-lite'

PrimaryInput = require '../primary_input'
PrimaryButton = require '../primary_button'
FlatButton = require '../flat_button'
InfoBlock = require '../info_block'
Form = require '../form'

if window?
  require './index.styl'

module.exports = class Join
  constructor: ({@model, @router}) ->
    @$signInButton = new FlatButton()
    @$createAccountButton = new PrimaryButton()

    @emailValue = new Rx.BehaviorSubject ''
    @usernameValue = new Rx.BehaviorSubject ''
    @passwordValue = new Rx.BehaviorSubject ''
    @emailError = new Rx.BehaviorSubject null
    @usernameError = new Rx.BehaviorSubject null
    @passwordError = new Rx.BehaviorSubject null
    @$emailInput = new PrimaryInput
      value: @emailValue
      error: @emailError
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
    @model.auth.join {
      email: @emailValue.getValue()
      username: @usernameValue.getValue()
      password: @passwordValue.getValue()
    }
    .then =>
      @state.set isLoading: false
      @router.go '/policies'
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
            z @$emailInput,
              hintText: 'Email'

            z @$usernameInput,
              hintText: 'Username'

            z @$passwordInput,
              type: 'password'
              hintText: 'Password'
          ]
          $buttons: [
            z @$createAccountButton,
              text: if isLoading then 'Loading...' else 'Create account'
              type: 'submit'

            z @$signInButton,
              text: 'Sign in'
              onclick: =>
                @router.go '/signIn'

          ]
