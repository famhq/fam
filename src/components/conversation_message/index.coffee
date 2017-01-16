z = require 'zorium'
moment = require 'moment'
supportsWebP = window? and require 'supports-webp'
_map = require 'lodash/map'
_filter = require 'lodash/filter'
_truncate = require 'lodash/truncate'

Icon = require '../icon'
Avatar = require '../avatar'
ConversationImageView = require '../conversation_image_view'
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

ALL_REGEX_STR = "#{config.STICKER_REGEX_STR}|#{config.URL_REGEX_STR}|" +
                  "#{config.IMAGE_REGEX_BASE_STR}"
ALL_REGEX = new RegExp ALL_REGEX_STR, 'gi'
TITLE_LENGTH = 30
DESCRIPTION_LENGTH = 100

module.exports = class ConversationMessage
  constructor: (options) ->
    {message, isGrouped, isMe, @model, @overlay$,
      @selectedProfileDialogUser} = options

    @$avatar = new Avatar()

    @imageData = new Rx.BehaviorSubject null
    @$conversationImageView = new ConversationImageView {
      @model
      @imageData
      @overlay$
      @router
    }

    @state = z.state
      message: message
      isMe: isMe
      isGrouped: isGrouped
      windowSize: @model.window.getSize()

  formatMessage: (message) =>
    textLines = message.split('\n') or []
    _map textLines, (text) =>
      parts = _filter text.split ALL_REGEX
      z 'div',
        _map parts, (part) =>
          # need to create new regex each time (since exec grabs nth match)
          if part.match config.IMAGE_REGEX
            matches = new RegExp(config.LOCAL_IMAGE_REGEX_STR, 'gi').exec(part)
            if matches
              imageUrl = "#{config.USER_CDN_URL}/cm/#{matches[3]}.small.png"
              largeImageUrl = "#{config.USER_CDN_URL}/cm/#{matches[3]}" +
                                '.large.png'
              imageAspectRatio = matches[4] / matches[5]
            else
              matches = new RegExp(config.IMAGE_REGEX_STR, 'gi').exec(part)
              imageUrl = matches[3].trim()
              if supportsWebP and imageUrl.indexOf('giphy.com') isnt -1
                imageUrl = imageUrl.replace /\.gif$/, '.webp'
              largeImageUrl = imageUrl
              imageAspectRatio = matches[4] / matches[5]

            z 'img', {
              src: imageUrl
              width: 200
              height: 200 / imageAspectRatio
              onclick: (e) =>
                e?.stopPropagation()
                e?.preventDefault()
                @overlay$.onNext @$conversationImageView
                @imageData.onNext {
                  url: largeImageUrl
                  aspectRatio: imageAspectRatio
                }
            }
          else if part.match config.STICKER_REGEX
            sticker = part.replace /:/g, ''
            z '.sticker',
              style:
                backgroundImage:
                  "url(#{config.CDN_URL}/groups/emotes/#{sticker}.png)"

          else if part.match config.URL_REGEX
            z 'a.link', {
              href: part
              onclick: (e) =>
                e?.stopPropagation()
                e?.preventDefault()
                @model.portal.call 'browser.openWindow', {
                  url: part
                  target: '_system'
                }
            }, part
          else
            part

  render: ({isTextareaFocused}) =>
    {isMe, message, isGrouped, windowSize} = @state.getValue()

    {user, body, time, card, id, clientId} = message

    isSticker = body.match /^:[a-z_]+:$/

    onclick = =>
      unless isTextareaFocused
        @selectedProfileDialogUser.onNext user

    z '.z-conversation-message', {
      # re-use elements in v-dom
      key: "message-#{id or clientId}"
      className: z.classKebab {isSticker, isGrouped, isMe}
    },
      z '.avatar', {onclick},
        z @$avatar, {
          user
          size: if windowSize.width > 840 \
                then '56px'
                else '40px'
          bgColor: colors.$grey200
        }
      z '.bubble', {onclick},
        z '.body',
            @formatMessage body
        z '.bottom',
          z '.name', @model.user.getDisplayName user
          z '.middot',
            innerHTML: '&middot;'
          z '.time',
            if time
            then moment(time).fromNowModified()
            else '...'
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
