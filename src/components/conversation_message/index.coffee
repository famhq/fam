z = require 'zorium'
moment = require 'moment'
_map = require 'lodash/map'
_filter = require 'lodash/filter'
_truncate = require 'lodash/truncate'

Icon = require '../icon'
Avatar = require '../avatar'
ConversationImageView = require '../conversation_image_view'
Ripple = require '../ripple'
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

    @imageData = new Rx.BehaviorSubject null
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

    {user, body, time, card, id, clientId} = message

    isSticker = body.match /^:[a-z_]+:$/
    avatarSize = if windowSize.width > 840 \
                 then '56px'
                 else '40px'

    onclick = =>
      unless isTextareaFocused
        @selectedProfileDialogUser.onNext user

    z '.z-conversation-message', {
      # re-use elements in v-dom
      key: "message-#{id or clientId}"
      onclick: onclick
      className: z.classKebab {isSticker, isGrouped, isMe}
    },
      z '.avatar', {
        onclick
        style:
          width: avatarSize
      },
        unless isGrouped
          z @$avatar, {
            user
            size: avatarSize
            bgColor: colors.$grey200
          }

      z '.content',
        unless isGrouped
          z '.author',
            z '.name', @model.user.getDisplayName user
            z '.middot',
              innerHTML: '&middot;'
            z '.time',
              if time
              then moment(time).fromNowModified()
              else '...'

        z '.body', $body

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
      @$ripple
