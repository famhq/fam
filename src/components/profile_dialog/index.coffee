z = require 'zorium'

Avatar = require '../avatar'
Dialog = require '../dialog'
Icon = require '../icon'
colors = require '../../colors'
config = require '../../config'

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
    @$deleteIcon = new Icon()
    @$chevronIcon = new Icon()
    @$closeIcon = new Icon()
    @$copyIcon = new Icon()

    me = @model.user.getMe()

    @state = z.state
      me: me
      user: @selectedProfileDialogUser
      clashRoyaleData: @selectedProfileDialogUser.flatMapLatest (user) =>
        if user
          @model.player.getByUserIdAndGameId user.id, config.CLASH_ROYALE_ID
        else
          Rx.Observable.just null
      group: group
      isFlagLoading: false
      isFlagged: false
      isConversationLoading: false

  afterMount: =>
    @router.onBack =>
      @selectedProfileDialogUser.onNext null

  beforeUnmount: =>
    @router.onBack null

  render: =>
    {me, user, platform, isFlagLoading, isFlagged, group, clashRoyaleData,
      isConversationLoading} = @state.getValue()

    isBlocked = @model.user.isBlocked me, user?.id
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
                z @$avatar, {user, bgColor: colors.$grey100, size: '72px'}
              z '.about',
                z '.name', @model.user.getDisplayName user
                z '.roles', clashRoyaleData?.data?.clan?.name
              z '.close',
                z '.icon',
                  z @$closeIcon,
                    icon: 'close'
                    color: colors.$primary500
                    isAlignedTop: true
                    isAlignedRight: true
                    onclick: =>
                      @selectedProfileDialogUser.onNext null

            z 'ul.content',
              unless isMe
                z 'li.menu-item', {
                  onclick: =>
                    @router.go "/user/id/#{user?.id}"
                    @selectedProfileDialogUser.onNext null
                },
                  z '.icon',
                    z @$profileIcon,
                      icon: 'profile'
                      color: colors.$primary500
                      isTouchTarget: false
                  z '.text', @model.l.get 'general.profile'

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
                    then @model.l.get 'general.loading'
                    else @model.l.get 'profileDialog.message'

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
                    if isBlocked \
                    then @model.l.get 'profileDialog.unblock'
                    else @model.l.get 'profileDialog.block'


              # if user?.chatMessageId
              #   z 'li.menu-item', {
              #     onclick: =>
              #       null # TODO
              #   },
              #     z '.icon',
              #       z @$copyIcon,
              #         icon: 'copy'
              #         color: colors.$primary500
              #         isTouchTarget: false
              #     z '.text', @model.l.get 'profileDialog.copy'






              # if not isMe #and user?.chatMessageId and not me?.flags.isModerator
              #   z 'li.menu-item', {
              #     onclick: =>
              #       @selectedProfileDialogUser.onNext null
              #       # @state.set isFlagLoading: true
              #       # @model.threadComment.flag user?.chatMessageId
              #       # .then =>
              #       #   @state.set isFlagLoading: false, isFlagged: true
              #   },
              #     z '.icon',
              #       z @$flagIcon,
              #         icon: 'warning'
              #         color: colors.$primary500
              #         isTouchTarget: false
              #     z '.text',
              #       if isFlagLoading \
              #       then @model.l.get 'general.loading'
              #       else if isFlagged
              #       then @model.l.get 'profileDialog.reported'
              #       else @model.l.get 'profileDialog.report'

              if me?.flags?.isModerator
                z '.divider'

              if me?.flags?.isModerator and not isMe
                z 'li.menu-item', {
                  onclick: =>
                    @model.user.setFlagsById user?.id, {
                      isChatBanned: not user?.flags?.isChatBanned
                    }
                    @selectedProfileDialogUser.onNext null
                },
                  z '.icon',
                    z @$banIcon,
                      icon: 'warning'
                      color: colors.$primary500
                      isTouchTarget: false
                  z '.text',
                    if user?.flags?.isChatBanned
                      @model.l.get 'profileDialog.chatBanned'
                    else
                      @model.l.get 'profileDialog.ban'

              if me?.flags?.isModerator and user?.chatMessageId
                z 'li.menu-item', {
                  onclick: =>
                    @model.chatMessage.deleteById user?.chatMessageId
                    @selectedProfileDialogUser.onNext null
                },
                  z '.icon',
                    z @$deleteIcon,
                      icon: 'delete'
                      color: colors.$primary500
                      isTouchTarget: false
                  z '.text',
                    @model.l.get 'profileDialog.delete'

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
                    z '.text', 'Manage'
                ]
