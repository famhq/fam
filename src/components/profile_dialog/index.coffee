z = require 'zorium'

Avatar = require '../avatar'
Dialog = require '../dialog'
Icon = require '../icon'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class ProfileDialog
  constructor: ({@model, @router, @selectedProfileDialogUser, group}) ->
    @$dialog = new Dialog()
    @$avatar = new Avatar()

    @$profileIcon = new Icon()
    @$friendIcon = new Icon()
    @$messageIcon = new Icon()
    @$manageIcon = new Icon()
    @$flagIcon = new Icon()
    @$blockIcon = new Icon()
    @$banIcon = new Icon()
    @$chevronIcon = new Icon()

    me = @model.user.getMe()

    @state = z.state
      me: me
      user: @selectedProfileDialogUser
      group: group
      isFlagLoading: false
      isFlagged: false
      isConversationLoading: false

  render: =>
    {me, user, platform, isFlagLoading, isFlagged, group,
      isConversationLoading} = @state.getValue()

    isBlocked = @model.user.isBlocked me, user?.id
    isFollowing = @model.user.isFollowing me, user?.id
    isMe = user?.id is me?.id
    hasAdminPermission = @model.group.hasPermission group, me, {level: 'admin'}

    z '.z-profile-dialog', {className: z.classKebab {isVisible: me and user}},
      z @$dialog,
        onLeave: =>
          @selectedProfileDialogUser.onNext null
        $content:
          z '.z-profile-dialog_dialog',
            z '.header', {
                # onclick: =>
                #   @router.go "/profile/#{user.id}"
            },
              z '.avatar',
                z @$avatar, {user, bgColor: colors.$grey100, size: '40px'}
              z '.about',
                z '.name', @model.user.getDisplayName user
                z '.roles', 'Member' # TODO
              # z '.chevron',
              #   z '.icon',
              #     z @$chevronIcon,
              #       icon: 'chevron-right'
              #       color: colors.$primary500

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
                      color: colors.$primary500
                      isTouchTarget: false
                  z '.text',
                    if isFollowing then 'Remove Friend' else 'Add Friend'

              unless isMe
                z 'li.menu-item', {
                  onclick: =>
                    unless isConversationLoading
                      @state.set isConversationLoading: true
                      @model.conversation.create {
                        userIds: [user.id]
                      }
                      .then (conversation) =>
                        @state.set isConversationLoading: false
                        @router.go "/conversation/#{conversation.id}"
                        @selectedProfileDialogUser.onNext null
                },
                  z '.icon',
                    z @$messageIcon,
                      icon: 'chat-bubble'
                      color: colors.$primary500
                      isTouchTarget: false
                  z '.text',
                    if isConversationLoading
                    then 'Loading...'
                    else 'Send message'

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
                      color: colors.$primary500
                      isTouchTarget: false
                  z '.text',
                    if isBlocked then 'Unblock user' else 'Block user'

              if not isMe #and user?.chatMessageId and not me?.flags.isModerator
                z 'li.menu-item', {
                  onclick: =>
                    @selectedProfileDialogUser.onNext null
                    # @state.set isFlagLoading: true
                    # @model.threadMessage.flag user?.chatMessageId
                    # .then =>
                    #   @state.set isFlagLoading: false, isFlagged: true
                },
                  z '.icon',
                    z @$flagIcon,
                      icon: 'warning'
                      color: colors.$primary500
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
                      color: colors.$primary500
                      isTouchTarget: false
                  z '.text',
                    if user?.flags?.isChatBanned
                      'User banned'
                    else
                      'Ban from chat'

              if group and hasAdminPermission
                [
                  z 'li.divider'
                  z 'li.menu-item', {
                    onclick: =>
                      @router.go "/group/#{group.id}/manage/#{user?.id}"
                  },
                    z '.icon',
                      z @$manageIcon,
                        icon: 'settings'
                        color: colors.$primary500
                        isTouchTarget: false
                    z '.text', 'Manage member'
                ]
