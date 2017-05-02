z = require 'zorium'
Rx = require 'rx-lite'

Dialog = require '../dialog'
PrimaryInput = require '../primary_input'
FlatButton = require '../flat_button'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class SignInDialog
  constructor: ({@model, @router}) ->

    @usernameValue = new Rx.BehaviorSubject ''
    @usernameError = new Rx.BehaviorSubject null
    @$usernameInput = new PrimaryInput
      value: @usernameValue
      error: @usernameError

    @passwordValue = new Rx.BehaviorSubject ''
    @passwordError = new Rx.BehaviorSubject null
    @$passwordInput = new PrimaryInput
      value: @passwordValue
      error: @passwordError

    @emailValue = new Rx.BehaviorSubject ''
    @emailError = new Rx.BehaviorSubject null
    @$emailInput = new PrimaryInput
      value: @emailValue
      error: @emailError

    @$submitButton = new FlatButton()
    @$cancelButton = new FlatButton()

    @$dialog = new Dialog()

    @state = z.state
      mode: @model.signInDialog.getMode()
      isLoading: false

  join: (e) =>
    e?.preventDefault()
    @state.set isLoading: true

    @model.auth.join {
      username: @usernameValue.getValue()
      password: @passwordValue.getValue()
      email: @emailValue.getValue()
    }
    .then =>
      @state.set isLoading: false
      @model.user.getMe().take(1).subscribe =>
        @model.signInDialog.loggedIn()
        @model.signInDialog.close()
    .catch (err) =>
      @usernameError.onNext err.message
      @state.set isLoading: false

  signIn: (e) =>
    e?.preventDefault()
    @state.set isLoading: true

    @model.auth.login {
      username: @usernameValue.getValue()
      password: @passwordValue.getValue()
    }
    .then =>
      @state.set isLoading: false
      @model.user.getMe().take(1).subscribe =>
        @model.signInDialog.loggedIn()
        @model.signInDialog.close()
    .catch (err) =>
      @usernameError.onNext err.message
      @state.set isLoading: false

  cancel: =>
    @model.signInDialog.close()

  render: =>
    {mode, isLoading} = @state.getValue()

    z '.z-sign-in-dialog',
      z @$dialog,
        onLeave: =>
          @model.signInDialog.close()
        $content:
          z '.z-sign-in-dialog_dialog',
            z '.header',
              z '.title',
                if mode is 'join'
                then 'Get started'
                else 'Welcome back'
              z '.button', {
                onclick: =>
                  @model.signInDialog.setMode(
                    if mode is 'join' then 'signIn' else 'join'
                  )
              },
                if mode is 'join' then 'Sign in' else 'Sign up'


            # z '.signup-facebook', {
            #   onclick: =>
            #     @state.set isFacebookSigninLoading: true
            #     @model.auth.loginFacebook {
            #       isLoginOnly: mode isnt 'join'
            #     }
            #     .then =>
            #       @state.set isFacebookSigninLoading: false
            #       @router.go redirectPath
            # }, 'LFB'
            z 'form.content',
              z '.input',
                z @$usernameInput, {
                  hintText: 'Username'
                }
              if mode is 'join'
                z '.input',
                  z @$emailInput, {
                    hintText: 'Email address'
                  }
              z '.input',
                z @$passwordInput, {
                  type: 'password'
                  hintText: 'Password'
                }
              z '.actions',
                z '.button',
                  z @$submitButton,
                    text: if isLoading \
                          then 'Loading...'
                          else if mode is 'join'
                          then 'Create account'
                          else 'Sign in'
                    colors:
                      cText: colors.$primary500
                    onclick: (e) =>
                      if mode is 'signIn'
                        @signIn e
                      else
                        @join e
                    type: 'submit'
                z '.button',
                  z @$cancelButton,
                    text: @model.l.get 'general.cancel'
                    onclick: @cancel
