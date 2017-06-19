z = require 'zorium'
Rx = require 'rx-lite'
moment = require 'moment'
supportsWebP = window? and require 'supports-webp'
_map = require 'lodash/map'
_truncate = require 'lodash/truncate'

Icon = require '../icon'
Avatar = require '../avatar'
ConversationImageView = require '../conversation_image_view'
FormattedText = require '../formatted_text'
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

TITLE_LENGTH = 30

module.exports = class ThreadComment
  constructor: (options) ->
    {threadComment, isMe, @model, @overlay$,
      @selectedProfileDialogUser, @router} = options

    @$avatar = new Avatar()

    @imageData = new Rx.BehaviorSubject null
    @$conversationImageView = new ConversationImageView {
      @model
      @imageData
      @overlay$
      @router
    }

    @state = z.state
      threadComment: threadComment
      $body: new FormattedText {text: threadComment.body, @model, @router}
      isMe: isMe
      windowSize: @model.window.getSize()

  render: =>
    {isMe, threadComment, $body, windowSize} = @state.getValue()

    {creator, time, card, body, id, clientId} = threadComment

    isSticker = body.match /^:[a-z_]+:$/

    onclick = =>
      @selectedProfileDialogUser.onNext creator

    z '.z-thread-comment', {
      # re-use elements in v-dom
      key: "thread-comment-#{clientId or id}"
      onclick: onclick
      className: z.classKebab {isSticker, isMe}
    },
      z '.avatar', {
        onclick
        style:
          width: '20px'
      },
        z @$avatar, {
          user: creator
          size: '20px'
          bgColor: colors.$grey200
        }

      z '.content',
        z '.author',
          z '.name', @model.user.getDisplayName creator
          z 'span', innerHTML: '&nbsp;&middot;&nbsp;'
          z '.time',
            if time
            then moment(time).fromNowModified()
            else '...'

        z '.body', $body

        if card
          z '.card', {
            onclick: (e) =>
              e?.stopPropagation()
              @model.portal.call 'browser.openWindow', {
                url: card.url
                target: '_system'
              }
          },
            z '.title', _truncate card.title, {length: TITLE_LENGTH}
            z '.description', _truncate card.description, {
              length: DESCRIPTION_LENGTH
            }
