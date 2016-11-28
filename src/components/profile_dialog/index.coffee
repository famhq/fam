z = require 'zorium'
Rx = require 'rx-lite'
colors = require '../../colors'
_isEmpty = require 'lodash/lang/isEmpty'
Dialog = require 'zorium-paper/dialog'
Environment = require 'clay-environment'
moment = require 'moment'

config = require '../../config'
Avatar = require '../avatar'
Icon = require '../icon'

if window?
  require './index.styl'

module.exports = class ProfileDialog
  constructor: ({@model, @router, @selectedProfileDialogUser}) ->
    @$dialog = new Dialog()
    @$avatar = new Avatar()

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
      platform: Environment.getPlatform {gameKey: config.GAME_KEY}

  render: =>
    {me, user, platform, isFlagLoading, isFlagged} = @state.getValue()

    isBlocked = @model.user.isBlocked me, user?.id
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

              if true #not isMe and user?.chatMessageId and not me?.flags.isModerator
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

              # if me?.flags?.isModerator and not isMe
              #   z 'li.menu-item', {
              #     onclick: =>
              #       @model.user.updateById user?.id, {
              #         flags:
              #           isChatBanned: not user?.flags?.isChatBanned
              #       }
              #       @selectedProfileDialogUser.onNext null
              #   },
              #     z '.icon',
              #       z @$banIcon,
              #         icon: 'lock'
              #         color: colors.$tertiary900
              #         isTouchTarget: false
              #     z '.text',
              #       if user?.flags?.isChatBanned
              #         'User banned'
              #       else
              #         'Ban from chat'
