z = require 'zorium'
supportsWebP = window? and require 'supports-webp'
remark = require 'remark'
vdom = require 'remark-vdom'
_uniq = require 'lodash/uniq'
_find = require 'lodash/find'
_reduce = require 'lodash/reduce'
RxObservable = require('rxjs/Observable').Observable
require 'rxjs/add/observable/of'

Sticker = require '../sticker'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class FormattedText
  constructor: (options) ->
    {text, @imageWidth, model, @router, @skipImages, @mentionedUsers,
      @selectedProfileDialogUser} = options

    unless text?.map
      @$el = @get$ {text, model}

    @state = z.state {
      $el: text?.map?((text) => @get$ {text, model})
    }

  get$: ({text, model}) =>
    isSticker = text?.match /^:[a-z_\^0-9]+:$/

    stickers = _uniq text?.match /:[a-z_\^0-9]+:/g
    text = _reduce stickers, (newText, find) ->
      stickerText = find.replace /:/g, ''
      parts = stickerText.split '^'
      sticker = parts[0]
      level = parts[1] or 1
      newText.replace(
        find
        "![sticker](#{config.CDN_URL}/stickers/#{sticker}_#{level}_tiny.png)"
      )
    , text

    mentions = text?.match config.MENTION_REGEX
    text = _reduce mentions, (newText, find) ->
      # TODO: change clash-royale
      username = find.replace('@', '').toLowerCase()
      newText.replace(
        find
        "[#{find}](/clash-royale/user/#{username} \"user:#{username}\")"
      )
    , text

    remark()
    .use vdom, {
      components:
        img: (tagName, props, children) =>
          isSticker = props.alt is 'sticker'

          if not props.src or (@skipImages and isSticker)
            return

          imageWidth = if isSticker \
                       then 30
                       else if @imageWidth is 'auto' \
                       then undefined
                       else 200

          imageAspectRatioRegex = /%20=([0-9.]+)x([0-9.]+)/ig
          localImageRegex = ///
            #{config.USER_CDN_URL.replace '/', '\/'}/cm/(.*?)\.
          ///ig
          imageSrc = props.src

          if matches = imageAspectRatioRegex.exec imageSrc
            imageAspectRatio = matches[1] / matches[2]
            imageSrc = imageSrc.replace matches[0], ''
          else
            imageAspectRatio = null

          if matches = localImageRegex.exec imageSrc
            imageSrc = "#{config.USER_CDN_URL}/cm/#{matches[1]}.small.jpg"
            largeImageSrc = "#{config.USER_CDN_URL}/cm/#{matches[1]}.large.jpg"

          if supportsWebP and imageSrc.indexOf('giphy.com') isnt -1
            imageSrc = imageSrc.replace /\.gif$/, '.webp'

          largeImageSrc ?= imageSrc

          if isSticker
            z 'img.is-sticker', {
              src: imageSrc
              width: imageWidth
            }
          else
            z '.image-wrapper',
              z 'img', {
                src: imageSrc
                width: imageWidth
                height: if imageAspectRatio and @imageWidth isnt 'auto' \
                        then imageWidth / imageAspectRatio
                        else undefined
                onclick: (e) ->
                  e?.stopPropagation()
                  e?.preventDefault()
                  model.imageViewOverlay.setImageData {
                    url: largeImageSrc
                    aspectRatio: imageAspectRatio
                  }
              }

        a: (tagName, props, children) =>
          isMention = props.title and props.title.indexOf('user:') isnt -1
          z 'a.link', {
            href: props.href
            className: z.classKebab {isMention}
            onclick: (e) =>
              e?.stopPropagation()
              e?.preventDefault()
              if isMention and @selectedProfileDialogUser
                username = props.title.replace 'user:', ''
                user = _find @mentionedUsers, {username}
                @selectedProfileDialogUser.next user
              else
                @router.openLink props.href
          }, children
    }
    .process text
    .contents

  render: =>
    {$el} = @state.getValue()

    z '.z-formatted-text',
      @$el or $el
