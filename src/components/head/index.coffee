_ = require 'lodash'
z = require 'zorium'
colors = require 'zorium-paper/colors.json'

config = require '../../config'

module.exports = class Head
  constructor: ({model, meta, serverData}) ->
    @state = z.state
      meta: meta
      serverData: serverData
      modelSerialization: model.getSerializationStream()

  render: =>
    {meta, serverData, modelSerialization} = @state.getValue()

    meta = _.merge {
      title: 'Red Tritium'
      description: 'Have what it takes?'
      icon256: '/images/zorium_icon_256.png'
      twitter:
        siteHandle: '@ZoriumJS'
        creatorHandle: '@ZoriumJS'
        title: undefined
        description: undefined
        # min 280 x 150 < 1MB
        image: '/images/zorium_icon_1024.png'

      openGraph:
        title: undefined
        url: undefined
        description: undefined
        siteName: 'Red Tritium'
        # min 200 x 200, min reccomended 600 x 315, reccomended 1200 x 630
        image: '/images/zorium_icon_1024.png'

      ios:
        # min 152 x 152
        icon: undefined

      canonical: undefined
      themeColor: colors.$teal700
      # reccomended 32 x 32 png
      favicon: '/images/zorium_icon_32.png'
      manifestUrl: '/manifest.json'
    }, meta

    meta = _.merge {
      twitter:
        title: meta.title
        description: meta.description
      openGraph:
        title: meta.title
        url: meta.canonical
        description: meta.description
      ios:
        icon: meta.icon256
    }, meta

    {twitter, openGraph, ios, kik} = meta

    isInliningSource = config.ENV is config.ENVS.PROD
    webpackDevUrl = config.WEBPACK_DEV_URL

    z 'head',
      z 'title', "#{meta.title}"
      z 'meta', {name: 'description', content: "#{meta.description}"}

      # Appcache
      # TODO: re-enable
      # if config.ENV is config.ENVS.PROD
      #   z 'iframe',
      #     src: '/manifest.html'
      #     style:
      #       width: 0
      #       height: 0
      #       visibility: 'hidden'
      #       position: 'absolute'
      #       border: 'none'

      # mobile
      z 'meta',
        name: 'viewport'
        content: 'initial-scale=1.0, width=device-width, minimum-scale=1.0,
                  maximum-scale=1.0, user-scalable=0, minimal-ui'

      # Twitter card
      z 'meta', {name: 'twitter:card', content: 'summary_large_image'}
      z 'meta', {name: 'twitter:site', content: "#{twitter.siteHandle}"}
      z 'meta', {name: 'twitter:creator', content: "#{twitter.creatorHandle}"}
      z 'meta', {name: 'twitter:title', content: "#{twitter.title}"}
      z 'meta', {name: 'twitter:description', content: "#{twitter.description}"}
      z 'meta', {name: 'twitter:image:src', content: "#{twitter.image}"}

      # Open Graph
      z 'meta', {property: 'og:title', content: "#{openGraph.title}"}
      z 'meta', {property: 'og:type', content: 'website'}
      z 'meta', {property: 'og:url', content: "#{openGraph.url}"}
      z 'meta', {property: 'og:image', content: "#{openGraph.image}"}
      z 'meta', {
        property: 'og:description', content: "#{openGraph.description}"
      }
      z 'meta', {property: 'og:site_name', content: "#{openGraph.siteName}"}

      # iOS
      z 'meta', {name: 'apple-mobile-web-app-capable', content: 'yes'}
      z 'link', {rel: 'apple-touch-icon', href: "#{ios.icon}"}

      # misc
      z 'link', {rel: 'canonical', href: "#{meta.canonical}"}
      z 'meta', {name: 'theme-color', content: "#{meta.themeColor}"}
      z 'link', {rel: 'icon', href: "#{meta.favicon}"}
      z 'meta', {name: 'msapplication-tap-highlight', content: 'no'}

      # Android
      z 'link', {rel: 'manifest', href: "#{meta.manifestUrl}"}

      # serialization
      z 'script.model',
        innerHTML: modelSerialization or ''

      z 'script',
        src: 'https://cdn.kik.com/kik/2.3.6/kik.js'

      # fonts
      z 'link',
        rel: 'stylesheet'
        type: 'text/css'
        href: 'https://fonts.googleapis.com/css?family=Roboto:300,400,500,700'

      # styles
      if isInliningSource
        z 'style.styles',
          innerHTML: serverData?.styles
      else
        null

      # scripts
      z 'script.bundle',
        async: true
        src: if isInliningSource then serverData?.bundlePath \
             else "#{webpackDevUrl}/bundle.js"
