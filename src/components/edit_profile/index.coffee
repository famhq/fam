z = require 'zorium'
log = require 'loga'
Rx = require 'rx-lite'
Button = require 'zorium-paper/button'

Avatar = require '../avatar'
Icon = require '../icon'
UploadOverlay = require '../upload_overlay'
PrimaryButton = require '../primary_button'
PrimaryInput = require '../primary_input'
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class EditProfile
  constructor: ({@model, @router}) ->
    me = @model.user.getMe()
    @usernameValue = new Rx.BehaviorSubject ''
    @usernameError = new Rx.BehaviorSubject null
    # FIXME: there's a better way to do this
    me.take(1).subscribe (me) => @usernameValue.onNext me?.username

    # @selectedPresetAvatarStreams = new Rx.ReplaySubject 1
    # @selectedPresetAvatarStreams.onNext me.map (me) ->
    #   me?.data.presetAvatarId

    @$discardIcon = new Icon()
    @$doneIcon = new Icon()

    @$avatar = new Avatar()
    @$avatarButton = new PrimaryButton()
    @$uploadOverlay = new UploadOverlay {@model}

    @$usernameInput = new PrimaryInput
      value: @usernameValue
      error: @usernameError

    @state = z.state
      me: me
      avatarImage: null
      avatarDataUrl: null
      avatarUploadError: null
      isSaving: false
      # selectedPresetAvatar: @selectedPresetAvatarStreams.switch()

  # beforeUnmount: =>
  #   @selectedPresetAvatarStreams.onNext @model.user.getMe().map (me) ->
  #     me?.data.presetAvatarId

  save: =>
    {avatarImage, selectedPresetAvatar, me, isSaving} = @state.getValue()
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
      console.log '123'
      if avatarImage
        console.log 'up'
        @upload avatarImage
    .then =>
      @state.set isSaving: false
      @router.go '/profile'

  upload: (file) =>
    console.log '1234'
    @model.user.setAvatarImage file
    .then (response) =>
      @state.set
        avatarImage: null
        avatarDataUrl: null
        avatarUploadError: null
    .catch (err) =>
      @state.set avatarUploadError: err?.detail or JSON.stringify err

  render: =>
    {me, avatarUploadError, avatarDataUrl, isSaving,
      selectedPresetAvatar} = @state.getValue()

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

      # z '.presets',
      #   z '.title', 'Or pick a preset'
      #   z '.g-grid',
      #     z '.g-cols',
      #       _map config.PLAYER_AVATARS, (id) =>
      #         isSelected = selectedPresetAvatar is id
      #         z '.g-col.g-xs-3.g-md-2',
      #           z '.preset', {
      #             className: z.classKebab {isSelected}
      #           },
      #             z '.inner',
      #               style:
      #                 backgroundImage:
      #                   "url(#{config.CDN_URL}/avatars/#{id}.png)"
      #               onclick: =>
      #                 @selectedPresetAvatarStreams.onNext Rx.Observable.just id
