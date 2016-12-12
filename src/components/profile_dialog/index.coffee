z = require 'zorium'
Dialog = require 'zorium-paper/dialog'

Avatar = require '../avatar'
Icon = require '../icon'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class ProfileDialog
  constructor: ({@model, @router, @selectedProfileDialogUser}) ->
    @$dialog = new Dialog()
    @$avatar = new Avatar()

    @$profileIcon = new Icon()
    @$friendIcon = new Icon()
    @$messageIcon = new Icon()
    @$flagIcon = new Icon()
    @$blockIcon = new Icon()
    @$banIcon = new Icon()
    @$closeIcon = new Icon()

    me = @model.user.getMe()

    @state = z.state
      me: me
      user: @selectedProfileDialogUser
      isFlagLoading: false
      isFlagged: false

  render: =>
    {me, user, platform, isFlagLoading, isFlagged} = @state.getValue()

    isBlocked = @model.user.isBlocked me, user?.id
    isFollowing = @model.user.isFollowing me, user?.id
    isMe = user?.id is me?.id

    z '.z-profile-dialog',
      z @$dialog,
        $content:
          z '.z-profile-dialog_dialog',
            z '.header',
              z '.avatar',
                z @$avatar, {user, bgColor: colors.$grey100}
              z '.about',
                z '.name', @model.user.getDisplayName user
              z '.close', {
                onclick: =>
                  @selectedProfileDialogUser.onNext null
              },
                z '.icon',
                  z @$closeIcon,
                    icon: 'close'
                    color: colors.$white

            z 'ul.content',
              unless isMe
                z 'li.menu-item', {
                  onclick: =>
                    if isFollowing
                      @model.userData.unfollowByUserId user?.id
                    else
                      @model.userData.followByUserId user?.id
                    @selectedProfileDialogUser.onNext null
                },
                  z '.icon',
                    z @$friendIcon,
                      icon: if isFollowing \
                            then 'remove-friend'
                            else 'add-friend'
                      color: colors.$tertiary500
                      isTouchTarget: false
                  z '.text',
                    if isFollowing then 'Remove Friend' else 'Add Friend'

              unless isMe
                z 'li.menu-item', {
                  onclick: =>
                    @router.go "/chat/user/#{user?.id}"
                    @selectedProfileDialogUser.onNext null
                },
                  z '.icon',
                    z @$messageIcon,
                      icon: 'chat-bubble'
                      color: colors.$tertiary500
                      isTouchTarget: false
                  z '.text',
                    'Send message'

              unless isMe
                z 'li.menu-item', {
                  onclick: =>
                    if isBlocked
                      @model.userData.unblockByUserId user?.id
                    else
                      @model.userData.blockByUserId user?.id
                    @selectedProfileDialogUser.onNext null
                },
                  z '.icon',
                    z @$blockIcon,
                      icon: 'block'
                      color: colors.$tertiary900
                      isTouchTarget: false
                  z '.text',
                    if isBlocked then 'Unblock user' else 'Block user'

              if not isMe and user?.chatMessageId and not me?.flags.isModerator
                z 'li.menu-item', {
                  onclick: =>
                    @state.set isFlagLoading: true
                    @model.threadMessage.flag user?.chatMessageId
                    .then =>
                      @state.set isFlagLoading: false, isFlagged: true
                },
                  z '.icon',
                    z @$flagIcon,
                      icon: 'warning'
                      color: colors.$tertiary900
                      isTouchTarget: false
                  z '.text',
                    if isFlagLoading \
                    then 'Loading...'
                    else if isFlagged
                    then 'Reported'
                    else 'Report post'

              if me?.flags?.isModerator and not isMe
                z 'li.menu-item', {
                  onclick: =>
                    @model.user.updateById user?.id, {
                      flags:
                        isChatBanned: not user?.flags?.isChatBanned
                    }
                    @selectedProfileDialogUser.onNext null
                },
                  z '.icon',
                    z @$banIcon,
                      icon: 'lock'
                      color: colors.$tertiary900
                      isTouchTarget: false
                  z '.text',
                    if user?.flags?.isChatBanned
                      'User banned'
                    else
                      'Ban from chat'
