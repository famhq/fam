z = require 'zorium'
Rx = require 'rx-lite'

Avatar = require '../avatar'
Icon = require '../icon'
UploadOverlay = require '../upload_overlay'
PrimaryButton = require '../primary_button'
PrimaryInput = require '../primary_input'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class EditProfile
  constructor: ({@model, @router}) ->
    me = @model.user.getMe()
    @usernameValueStreams = new Rx.ReplaySubject 1
    @usernameValueStreams.onNext me.map (me) ->
      me.username
    @usernameError = new Rx.BehaviorSubject null

    @$discardIcon = new Icon()
    @$doneIcon = new Icon()

    @$avatar = new Avatar()
    @$avatarButton = new PrimaryButton()
    @$uploadOverlay = new UploadOverlay {@model}

    @$usernameInput = new PrimaryInput
      valueStreams: @usernameValueStreams
      error: @usernameError

    @state = z.state
      me: me
      avatarImage: null
      avatarDataUrl: null
      avatarUploadError: null
      isSaving: false

  save: =>
    {avatarImage, me, isSaving} = @state.getValue()
    if isSaving
      return

    @state.set isSaving: true
    @usernameError.onNext null

    username = @usernameValue.getValue()
    (if username and username isnt me?.username
      @model.user.setUsername username
      .catch (err) =>
        @usernameError.onNext JSON.stringify err
    else
      Promise.resolve null)
    .then =>
      if avatarImage
        @upload avatarImage
    .then =>
      @state.set isSaving: false
      @router.go '/profile'

  upload: (file) =>
    @model.user.setAvatarImage file
    .then (response) =>
      @state.set
        avatarImage: null
        avatarDataUrl: null
        avatarUploadError: null
    .catch (err) =>
      @state.set avatarUploadError: err?.detail or JSON.stringify err

  render: =>
    {me, avatarUploadError, avatarDataUrl, isSaving} = @state.getValue()

    z '.z-edit-profile',
      z '.actions',
        z '.action', {
          onclick: =>
            @router.back()
        },
          z '.icon',
            z @$discardIcon,
              icon: 'close'
              color: colors.$primary500
              isTouchTarget: false
          z '.text', 'Cancel'
        z '.action', {
          onclick: @save
        },
          z '.icon',
            z @$doneIcon,
              icon: 'check'
              color: colors.$primary500
              isTouchTarget: false
          z '.text',
            if isSaving then 'Loading...' else 'Save'

      z '.section',
        z '.title', 'Change username'
        z '.input',
          z @$usernameInput,
            hintText: 'username...'

      z '.section',
        z '.title', 'Change avatar'
        if avatarUploadError
          avatarUploadError
        z '.flex',
          z '.avatar',
            z @$avatar, {src: avatarDataUrl, user: me, size: '64px'}
          z '.button',
            z @$avatarButton,
              text: 'Upload photo'
              isFullWidth: false
              onclick: null
            z '.upload-overlay',
              z @$uploadOverlay,
                onSelect: ({file, dataUrl}) =>
                  @state.set avatarImage: file, avatarDataUrl: dataUrl
