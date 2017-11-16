z = require 'zorium'
moment = require 'moment'
_map = require 'lodash/map'
_filter = require 'lodash/filter'
_truncate = require 'lodash/truncate'
_defaults = require 'lodash/defaults'
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject

Avatar = require '../avatar'
Icon = require '../icon'
ConversationImageView = require '../conversation_image_view'
Ripple = require '../ripple'
FormatService = require '../../services/format'
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

TITLE_LENGTH = 30
DESCRIPTION_LENGTH = 100

module.exports = class ConversationMessage
  constructor: (options) ->
    {message, $body, isGrouped, isMe, @model, @overlay$,
      @selectedProfileDialogUser, @router} = options

    @$avatar = new Avatar()
    @$ripple = new Ripple()
    @$trophyIcon = new Icon()
    @$statusIcon = new Icon()
    @$verifiedIcon = new Icon()

    @imageData = new RxBehaviorSubject null
    @$conversationImageView = new ConversationImageView {
      @model
      @imageData
      @overlay$
      @router
    }

    @state = z.state
      message: message
      $body: $body
      isMe: isMe
      isGrouped: isGrouped
      windowSize: @model.window.getSize()

  render: ({isTextareaFocused}) =>
    {isMe, message, $body, isGrouped, windowSize} = @state.getValue()

    {user, groupUser, body, time, card, id, clientId} = message

    avatarSize = if windowSize.width > 840 \
                 then '40px'
                 else '40px'

    onclick = =>
      unless isTextareaFocused
        @selectedProfileDialogUser.next _defaults {
          chatMessageId: id
        }, user

    oncontextmenu = =>
      @selectedProfileDialogUser.next _defaults {
        chatMessageId: id
      }, user

    isVerified = user and user.gameData?.isVerified

    z '.z-conversation-message', {
      # re-use elements in v-dom. doesn't seem to work with prepending more
      key: "message-#{id or clientId}"
      className: z.classKebab {isGrouped, isMe}
      oncontextmenu: (e) ->
        e?.preventDefault()
        oncontextmenu?()
    },
      z '.avatar', {
        onclick
        style:
          width: avatarSize
      },
        unless isGrouped
          z @$avatar, {
            user
            groupUser
            size: avatarSize
            bgColor: colors.$grey200
          }
        # z '.level', 1

      z '.content',
        unless isGrouped
          z '.author', {onclick},
            if user?.flags?.isDev
              z '.icon',
                z @$statusIcon,
                  icon: 'dev'
                  color: colors.$white
                  isTouchTarget: false
                  size: '22px'
            else if user?.flags?.isModerator
              z '.icon',
                z @$statusIcon,
                  icon: 'mod'
                  color: colors.$white
                  isTouchTarget: false
                  size: '22px'
            else if user?.flags?.isStar
              z '.icon',
                z @$statusIcon,
                  icon: 'star-tag'
                  color: colors.$white
                  isTouchTarget: false
                  size: '22px'
            z '.name', @model.user.getDisplayName user
            if isVerified
              z '.verified',
                z @$verifiedIcon,
                  icon: 'verified'
                  color: colors.$secondary500
                  isTouchTarget: false
                  size: '14px'
            z '.time',
              if time
              then moment(time).fromNowModified()
              else '...'
            z '.middot',
              innerHTML: '&middot;'
            z '.trophies',
              FormatService.number user?.gameData?.data?.trophies
              z '.icon',
                z @$trophyIcon,
                  icon: 'trophy'
                  color: colors.$white54
                  isTouchTarget: false
                  size: '16px'

        z '.body',
          $body

        if card
          z '.card', {
            onclick: (e) =>
              e?.stopPropagation()
              @router.openLink card.url
          },
            z '.title', _truncate card.title, {length: TITLE_LENGTH}
            z '.description', _truncate card.description, {
              length: DESCRIPTION_LENGTH
            }
      # @$ripple
