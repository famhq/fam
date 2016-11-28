_ = require 'lodash'
z = require 'zorium'
log = require 'loga'
Rx = require 'rx-lite'

Icon = require '../icon'
PrimaryButton = require '../primary_button'
PrimaryInput = require '../primary_input'
Spinner = require '../spinner'
InfoBlock = require '../info_block'
Form = require '../form'
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class AcceptInvite
  constructor: ({@model, @router, code, user}) ->
    me = @model.user.getMe()

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

    @$spinner = new Spinner()
    @$infoBlock = new InfoBlock()
    @$form = new Form()

    @state = z.state
      me: me
      code: code
      user: user
      isLoading: false

  create: (e) =>
    e?.preventDefault()

    {code} = @state.getValue()

    @state.set isLoading: true
    @model.auth.loginByCode {
      code: code
      username: @usernameValue.getValue()
      password: @passwordValue.getValue()
    }
    .then =>
      @state.set isLoading: false
      @router.go '/policies'
    .catch (err) =>
      @state.set isLoading: false
      @usernameError.onNext err.message

  render: =>
    {me, code, user, isLoading} = @state.getValue()

    z '.z-accept-invite',
      if user?.id and not user?.username
        z @$infoBlock,
          $title: 'Congratulations'
          $content: [
            z 'p',
              "You've been selected to be an early member of Red Tritium"

            z 'p', "Now, let's get you an account..."
          ]
          $form: z @$form,
            onsubmit: @create
            $inputs: [
              z '.input',
                z @$usernameInput,
                  hintText: 'Username'
              z '.input',
                z @$passwordInput,
                  type: 'password'
                  hintText: 'Password'
            ]
            $buttons: [
              z @$signInButton,
                text: if isLoading then 'Loading...' else 'Continue'
                type: 'submit'
            ]
      else if user
        z @$infoBlock,
          $title: 'Invalid code'
      else
        @$spinner
