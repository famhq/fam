z = require 'zorium'
supportsWebP = window? and require 'supports-webp'
remark = require 'remark'
vdom = require 'remark-vdom'
Rx = require 'rxjs'

config = require '../../config'

if window?
  require './index.styl'

module.exports = class FormattedText
  constructor: ({text, @imageWidth, model, @router}) ->
    text = if text?.map then text else Rx.Observable.of text

    $el = text?.map?((text) => @get$ {text, model}) or @get$ {text, model}

    @state = z.state {
      $el
      windowSize: model.window.getSize()
    }

  get$: ({text, model}) =>
    {windowSize} = @state.getValue()

    isSticker = text?.match /^:[a-z_]+:$/

    if isSticker
      sticker = text.replace /:/g, ''
      return z '.sticker',
        style:
          backgroundImage:
            "url(#{config.CDN_URL}/groups/emotes/#{sticker}.png)"


    remark()
    .use vdom, {
      components:
        img: (tagName, props, children) =>
          unless props.src
            return

          imageWidth = if @imageWidth is 'auto' \
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
            imageSrc = "#{config.USER_CDN_URL}/cm/#{matches[1]}.small.png"
            largeImageSrc = "#{config.USER_CDN_URL}/cm/#{matches[1]}.large.png"

          if supportsWebP and imageSrc.indexOf('giphy.com') isnt -1
            imageSrc = imageSrc.replace /\.gif$/, '.webp'

          largeImageSrc ?= imageSrc


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
          z 'a.link', {
            href: props.href
            onclick: (e) =>
              e?.stopPropagation()
              e?.preventDefault()

              @router.openLink props.href
          }, children
    }
    .process text
    .contents

  render: =>
    {$el} = @state.getValue()

    z '.z-formatted-text',
      $el
