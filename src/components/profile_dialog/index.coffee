z = require 'zorium'
_map = require 'lodash/map'
_filter = require 'lodash/filter'
_isEmpty = require 'lodash/isEmpty'
RxObservable = require('rxjs/Observable').Observable
require 'rxjs/add/observable/of'
require 'rxjs/add/observable/combineLatest'
require 'rxjs/add/operator/switchMap'

Avatar = require '../avatar'
Dialog = require '../dialog'
Icon = require '../icon'
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class ProfileDialog
  constructor: (options) ->
    {@model, @router, @selectedProfileDialogUser, group, gameKey} = options
    @$dialog = new Dialog()
    @$avatar = new Avatar()

    @$profileIcon = new Icon()
    @$friendIcon = new Icon()
    @$messageIcon = new Icon()
    @$manageIcon = new Icon()
    @$flagIcon = new Icon()
    @$blockIcon = new Icon()
    @$tempBanIcon = new Icon()
    @$permaBanIcon = new Icon()
    @$ipBanIcon = new Icon()
    @$deleteIcon = new Icon()
    @$chevronIcon = new Icon()
    @$closeIcon = new Icon()
    @$copyIcon = new Icon()

    me = @model.user.getMe()

    groupAndMe = RxObservable.combineLatest(
      group or RxObservable.of null
      me
      (vals...) -> vals
    )

    @state = z.state
      me: me
      meGroupUser: groupAndMe.switchMap ([group, me]) =>
        if group and me
          @model.groupUser.getByGroupIdAndUserId group.id, me.id
        else
          RxObservable.of null
      user: @selectedProfileDialogUser
      gameKey: gameKey
      clashRoyaleData: @selectedProfileDialogUser.switchMap (user) =>
        if user
          @model.player.getByUserIdAndGameId user.id, config.CLASH_ROYALE_ID
        else
          RxObservable.of null
      group: group
      isFlagLoading: false
      isFlagged: false
      isConversationLoading: false

  afterMount: =>
    @router.onBack =>
      @selectedProfileDialogUser.next null

  beforeUnmount: =>
    @router.onBack null

  render: =>
    {me, user, meGroupUser, platform, isFlagLoading, isFlagged, group, clashRoyaleData,
      isConversationLoading, gameKey} = @state.getValue()

    isBlocked = @model.user.isBlocked me, user?.id
    isMe = user?.id is me?.id
    hasDeleteMessagePermission = @model.groupUser.hasPermission {
      group, meGroupUser, me
      permissions: ['deleteMessage']
    }
    hasTempBanPermission = @model.groupUser.hasPermission {
      group, meGroupUser, me
      permissions: ['tempBan']
    }
    hasPermaBanPermission = @model.groupUser.hasPermission {
      group, meGroupUser, me
      permissions: ['permaBan']
    }
    hasManagePermission = @model.groupUser.hasPermission {
      group, meGroupUser, me
      permissions: ['manageRoles']
    }

    userOptions = _filter [
      {
        icon: 'profile'
        $icon: @$profileIcon
        text: @model.l.get 'general.profile'
        isVisible: not isMe
        onclick: =>
          @router.go 'userById', {gameKey, id: user?.id}
          @selectedProfileDialogUser.next null
      }
      {
        icon: 'chat-bubble'
        $icon: @$messageIcon
        text:
          if isConversationLoading
          then @model.l.get 'general.loading'
          else @model.l.get 'profileDialog.message'
        isVisible: not isMe
        onclick: =>
          unless isConversationLoading
            @state.set isConversationLoading: true
            @model.conversation.create {
              userIds: [user.id]
            }
            .then (conversation) =>
              @state.set isConversationLoading: false
              @router.go 'conversation', {gameKey, id: conversation.id}
              @selectedProfileDialogUser.next null
      }
      unless user?.flags?.isModerator
        {
          icon: 'block'
          $icon: @$blockIcon
          text:
            if isBlocked
            then @model.l.get 'profileDialog.unblock'
            else @model.l.get 'profileDialog.block'
          isVisible: not isMe
          onclick: =>
            if isBlocked
              @model.userData.unblockByUserId user?.id
            else
              @model.userData.blockByUserId user?.id
            @selectedProfileDialogUser.next null
        }
      # {
      #   icon: 'warning'
      #   $icon: @$flagIcon
      #   text:
      #     if isFlagLoading \
      #     then @model.l.get 'general.loading'
      #     else if isFlagged
      #     then @model.l.get 'profileDialog.reported'
      #     else @model.l.get 'profileDialog.report'
      #   isVisible: not isMe
      #   onclick: =>
      #     @selectedProfileDialogUser.next null
      #     # @state.set isFlagLoading: true
      #     # @model.threadComment.flag user?.chatMessageId
      #     # .then =>
      #     #   @state.set isFlagLoading: false, isFlagged: true
      # }
      # {
      #   icon: 'copy'
      #   $icon: @$copyIcon
      #   text: @model.l.get 'profileDialog.copy'
      #   isVisible: true
      #   onclick:-=> null # TODO
      # }
    ]

    modOptions = _filter [
      if hasTempBanPermission
        {
          icon: 'warning'
          $icon: @$tempBanIcon
          text:
            if user?.isChatBanned
              @model.l.get 'profileDialog.chatBanned'
            else
              @model.l.get 'profileDialog.tempBan'
          isVisible: not isMe
          onclick: =>
            if user?.isChatBanned
              @model.mod.unbanByUserId user?.id, {groupId: group?.id}
            else
              @model.mod.banByUserId user?.id, {
                duration: '24h', groupId: group?.id
              }
            @selectedProfileDialogUser.next null
        }
      if hasPermaBanPermission
        {
          icon: 'perma-ban'
          $icon: @$permaBanIcon
          text:
            if user?.isChatBanned
              @model.l.get 'profileDialog.chatBanned'
            else
              @model.l.get 'profileDialog.permaBan'
          isVisible: not isMe
          onclick: =>
            if user?.isChatBanned
              @model.mod.unbanByUserId user?.id, {groupId: group?.id}
            else
              @model.mod.banByUserId user?.id, {
                duration: 'permanent'
                groupId: group?.id
              }
            @selectedProfileDialogUser.next null
        }
      if hasPermaBanPermission
        {
          icon: 'ip-ban'
          $icon: @$ipBanIcon
          text:
            if user?.isChatBanned
              @model.l.get 'profileDialog.chatBanned'
            else
              @model.l.get 'profileDialog.ipBan'
          isVisible: not isMe
          onclick: =>
            if user?.isChatBanned
              @model.mod.unbanByUserId user?.id, {
                groupId: group?.id
              }
            else
              @model.mod.banByUserId user?.id, {
                type: 'ip', duration: 'permanent', groupId: group?.id
              }
            @selectedProfileDialogUser.next null
        }
      if hasDeleteMessagePermission
        {
          icon: 'delete'
          $icon: @$deleteIcon
          text: @model.l.get 'profileDialog.delete'
          isVisible: true
          onclick: =>
            @model.chatMessage.deleteById user?.chatMessageId
            @selectedProfileDialogUser.next null
        }
      if hasManagePermission
        {
          icon: 'settings'
          $icon: @$manageIcon
          text: @model.l.get 'general.manage'
          isVisible: true
          onclick: =>
            @router.go 'groupManage', {
              gameKey: gameKey, id: group.id, userId: user?.id
            }
            @selectedProfileDialogUser.next null
        }
    ]

    z '.z-profile-dialog', {className: z.classKebab {isVisible: me and user}},
      z @$dialog,
        onLeave: =>
          @selectedProfileDialogUser.next null
        $content:
          z '.z-profile-dialog_dialog',
            z '.header',
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
                      @selectedProfileDialogUser.next null

            z 'ul.content',
              _map userOptions, ({icon, $icon, text, onclick, isVisible}) ->
                z 'li.menu-item', {onclick},
                  z '.icon',
                    z $icon, {
                      icon: icon
                      color: colors.$primary500
                      isTouchTarget: false
                    }
                  z '.text', text

            if not _isEmpty modOptions
              z 'ul.content',
                z '.divider'
                _map modOptions, ({icon, $icon, text, onclick, isVisible}) ->
                  z 'li.menu-item', {onclick},
                    z '.icon',
                      z $icon, {
                        icon: icon
                        color: colors.$primary500
                        isTouchTarget: false
                      }
                    z '.text', text
