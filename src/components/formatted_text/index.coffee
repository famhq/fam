z = require 'zorium'
supportsWebP = window? and require 'supports-webp'
remark = require 'remark'
vdom = require 'remark-vdom'

config = require '../../config'

module.exports = class FormattedText
  constructor: ({text, model}) ->
    text = if text?.map then text else Rx.Observable.just text

    $el = text?.map?((text) => @get$ {text, model}) or @get$ {text, model}

    @state = z.state {$el}

  get$: ({text, model}) ->
    remark()
    .use vdom, {
      components:
        img: (tagName, props, children) ->
          unless props.src
            return

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
            width: 200
            height: if imageAspectRatio then 200 / imageAspectRatio else 'auto'
            onclick: (e) ->
              e?.stopPropagation()
              e?.preventDefault()
              model.imageViewOverlay.setImageData {
                url: largeImageSrc
                aspectRatio: imageAspectRatio
              }
          }
        a: (tagName, props, children) ->
          z 'a.link', {
            href: props.href
            onclick: (e) ->
              e?.stopPropagation()
              e?.preventDefault()
              model.portal.call 'browser.openWindow', {
                url: props.href
                target: '_system'
              }
          }, children
    }
    .process text
    .contents

  render: =>
    {$el} = @state.getValue()
    $el
