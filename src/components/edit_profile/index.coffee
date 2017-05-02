z = require 'zorium'
Rx = require 'rx-lite'

Avatar = require '../avatar'
Icon = require '../icon'
ActionBar = require '../action_bar'
UploadOverlay = require '../upload_overlay'
PrimaryButton = require '../primary_button'
SecondaryButton = require '../secondary_button'
PrimaryInput = require '../primary_input'
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class EditProfile
  constructor: ({@model, @router}) ->
    me = @model.user.getMe()

    @usernameValueStreams = new Rx.ReplaySubject 1
    @usernameValueStreams.onNext me.map (me) ->
      me.username
    @usernameError = new Rx.BehaviorSubject null

    @playerTagValueStreams = new Rx.ReplaySubject 1
    currentPlayerTag = me.flatMapLatest ({id}) =>
      @model.player.getByUserIdAndGameId id, config.CLASH_ROYALE_ID
      .map (player) ->
        player.playerId
    @playerTagValueStreams.onNext currentPlayerTag
    @playerTagError = new Rx.BehaviorSubject null

    @$actionBar = new ActionBar {@model}

    @$avatar = new Avatar()
    @$avatarButton = new PrimaryButton()
    @$uploadOverlay = new UploadOverlay {@model}

    @$forumSigButton = new SecondaryButton()
    @$logoutButton = new SecondaryButton()

    @$usernameInput = new PrimaryInput
      valueStreams: @usernameValueStreams
      error: @usernameError

    @$playerTagInput = new PrimaryInput
      valueStreams: @playerTagValueStreams
      error: @playerTagError

    @state = z.state
      me: me
      avatarImage: null
      avatarDataUrl: null
      avatarUploadError: null
      username: @usernameValueStreams.switch()
      playerTag: @playerTagValueStreams.switch()
      currentPlayerTag: currentPlayerTag
      isSaving: false

  save: =>
    {avatarImage, username, playerTag,
      me, isSaving, currentPlayerTag} = @state.getValue()
    if isSaving
      return

    @state.set isSaving: true
    @usernameError.onNext null

    (if username and username isnt me?.username
      @model.user.setUsername username
      .catch (err) =>
        @usernameError.onNext JSON.stringify err
    else
      Promise.resolve null)
    .then =>
      if playerTag isnt currentPlayerTag
        @model.clashRoyaleAPI.refreshByPlayerTag playerTag, {isUpdate: true}
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
      z @$actionBar, {
        isSaving
        cancel:
          onclick: =>
            @router.back()
        save:
          onclick: @save
      }

      z '.section',
        z '.input',
          z @$usernameInput,
            hintText: @model.l.get 'general.username'

        z '.input',
          z @$playerTagInput,
            hintText: @model.l.get 'editProfile.playerTagInputHintText'

      z '.section',
        z '.title', 'Change avatar'
        if avatarUploadError
          avatarUploadError
        z '.flex',
          z '.avatar',
            z @$avatar, {src: avatarDataUrl, user: me, size: '64px'}
          z '.button',
            z @$avatarButton,
              text: @model.l.get 'editProfile.avatarButtonText'
              isFullWidth: false
              onclick: null
            z '.upload-overlay',
              z @$uploadOverlay,
                onSelect: ({file, dataUrl}) =>
                  @state.set avatarImage: file, avatarDataUrl: dataUrl

      z '.section',
        z @$forumSigButton,
          text: @model.l.get 'editProfile.forumSigButtonText'
          onclick: =>
            @router.go '/forumSignature'

        z @$logoutButton,
          text: @model.l.get 'editProfile.logoutButtonText'
          onclick: =>
            @model.auth.logout()
            @router.go '/'
