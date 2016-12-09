_merge = require 'lodash/merge'
z = require 'zorium'
Environment = require 'clay-environment'

config = require '../../config'
colors = require '../../colors'

module.exports = class Head
  constructor: ({model, meta, serverData}) ->
    @state = z.state
      meta: meta
      serverData: serverData
      modelSerialization: model.getSerializationStream()

  render: =>
    {meta, serverData, modelSerialization} = @state.getValue()

    userAgent = navigator?.userAgent or serverData?.req?.headers?['user-agent']

    meta = _merge {
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
      themeColor: colors.$primary500
      # reccomended 32 x 32 png
      favicon: config.CDN_URL + '/favicon.png'
      manifestUrl: '/manifest.json'
    }, meta

    meta = _merge {
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

      z 'meta',
        'http-equiv': 'Content-Security-Policy'
        content: "default-src 'self' file://* *; style-src 'self'" +
          " 'unsafe-inline'; script-src 'self' 'unsafe-inline' 'unsafe-eval'"


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
        src: 'https://js.stripe.com/v2/'
      z 'script',
        innerHTML: "
          Stripe.setPublishableKey('#{config.STRIPE_PUBLISHABLE_KEY}');
        "

      z 'script',
        innerHTML: "
          (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||
          function(){(i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();
          a=s.createElement(o),m=s.getElementsByTagName(o)[0];a.async=1;
          a.src=g;m.parentNode.insertBefore(a,m)})(window,document,'script',
          '//www.google-analytics.com/analytics.js','ga');
          ga('create', '#{config.GOOGLE_ANALYTICS_ID}', 'auto');
        "

      if Environment.isGameApp(config.GAME_KEY, {userAgent})
        z 'script',
          innerHTML: 'window.kik = {}'
      else
        [
          z 'script',
            src: 'https://js.stripe.com/v2/'
          z 'script',
            innerHTML: "
              Stripe.setPublishableKey('#{config.STRIPE_PUBLISHABLE_KEY}');
            "
          z 'script',
            src: '//cdn.kik.com/kik/2.3.0/kik.js'

          z 'script',
            innerHTML: "
              (function(d, s, id) {
                var js, fjs = d.getElementsByTagName(s)[0];
                if (d.getElementById(id)) return;
                js = d.createElement(s); js.id = id;
                js.src = '//connect.facebook.net/en_US/sdk.js';
                fjs.parentNode.insertBefore(js, fjs);
              }(document, 'script', 'facebook-jssdk'));
              window.fbAsyncInit = function() {
                FB.init({
                  appId  : '#{config.FB_ID}',
                  cookie : true,
                  xfbml  : true,
                  version: 'v2.2'
                });
              }
            "
        ]

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
