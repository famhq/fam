z = require 'zorium'
Rx = require 'rx-lite'

Dialog = require '../dialog'
PrimaryInput = require '../primary_input'
Icon = require '../icon'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class LookingForFriendsDialog
  constructor: ({@model, @router, @overlay$}) ->

    @inviteLinkValue = new Rx.BehaviorSubject ''
    @inviteLinkError = new Rx.BehaviorSubject null
    @$inviteLinkInput = new PrimaryInput
      value: @inviteLinkValue
      error: @inviteLinkError

    @$dialog = new Dialog()
    @$chatIcon = new Icon()

    @state = z.state
      isLoading: false
      error: null
      language: @model.l.getLanguage()

  cancel: =>
    @overlay$.onNext null

  shareLink: (e) =>
    e?.preventDefault()
    {language} = @state.getValue()

    link = @inviteLinkValue.getValue()

    @state.set isLoading: true
    @model.findFriend.create {language, link}
    .then =>
      @state.set isLoading: false
      @overlay$.onNext null

  render: =>
    {step, isLoading, clan, error} = @state.getValue()

    z '.z-claim-clan-dialog',
      z @$dialog,
        onLeave: =>
          @overlay$.onNext null
        isVanilla: true
        $title: @model.l.get 'lookingForFriends.shareLink'
        $content:
          z '.z-looking-for-friends-dialog_dialog',
            z '.content',
              if error
                z '.error', error
              z '.text',
                @model.l.get 'lookingForFriendsDialog.text'
              z '.input',
                z @$inviteLinkInput,
                  hintText: @model.l.get 'lookingForFriendsDialog.inviteLink'
              z '.expires', @model.l.get 'lookingForFriendsDialog.expires'
        cancelButton:
          text: @model.l.get 'general.cancel'
          onclick: @cancel
        submitButton:
          text: if isLoading then 'loading...' \
                else @model.l.get 'general.share'
          onclick: @shareLink
