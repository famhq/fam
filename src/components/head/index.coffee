z = require 'zorium'
Environment = require '../../services/environment'
RxObservable = require('rxjs/Observable').Observable
_merge = require 'lodash/merge'
_map = require 'lodash/map'
_mapValues = require 'lodash/mapValues'
_defaults = require 'lodash/defaults'

config = require '../../config'
colors = require '../../colors'
rubikCss = require './rubik'

module.exports = class Head
  constructor: ({@model, meta, requests, serverData, group}) ->
    route = requests.map ({route}) -> route
    meta = requests.switchMap ({$page}) ->
      meta = $page?.getMeta?()
      if meta?.map
        meta
      else
        RxObservable.of meta

    @lastGroupId = null

    @state = z.state
      meta: meta
      serverData: serverData
      route: route
      group: group
      routeKey: route.map (route) =>
        if route?.src
          routeKey = @model.l.getRouteKeyByValue route.src
      modelSerialization: unless window?
        @model.getSerializationStream()
      cssVariables: group?.map (group) =>
        groupKey = group?.key
        if groupKey and groupKey.indexOf('clashroyale') isnt -1
          groupKey = 'clashroyale'
        if groupKey and groupKey.indexOf('fortnite') isnt -1
          groupKey = 'fortnite'
        if groupKey and groupKey.indexOf('brawlstars') isnt -1
          groupKey = 'brawlstars'

        cssColors = _defaults colors[groupKey], colors.default
        cssColors['--drawer-header-500'] ?= cssColors['--primary-500']
        cssColors['--drawer-header-500-text'] ?= cssColors['--primary-500-text']
        cssVariables = _map(cssColors, (value, key) ->
          "#{key}:#{value}"
        ).join ';'

        if @lastGroupId isnt group.id
          newStatusBarColor = cssColors['--status-bar-500'] or
                              cssColors['--primary-900']
          @model.portal?.call 'statusBar.setBackgroundColor', {
            color: newStatusBarColor
          }
          @lastGroupId = group.id
          @model.cookie.set "group_#{group.id}_lastVisit", Date.now()
          if cssVariables
            @model.cookie.set 'cachedCssVariables', cssVariables

        cssVariables

  render: =>
    {meta, serverData, route, routeKey, group,
      modelSerialization, cssVariables} = @state.getValue()

    paths = _mapValues @model.l.getAllPathsByRouteKey(routeKey), (path) ->
      pathVars = path.match /:([a-zA-Z0-9-]+)/g
      _map pathVars, (pathVar) ->
        path = path.replace pathVar, route.params[pathVar.substring(1)]
      path

    userAgent = navigator?.userAgent or serverData?.req?.headers?['user-agent']

    meta = _merge {
      title: 'global chat, stats and chest cycle tracker'
      description: 'Talk to other Clash Royale players, track your stats, and
                    set which chests you have next. Support for more mobile
                    games coming soon!'
      icon256: 'http://cdn.wtf/d/images/fam/web_icon_256.png'
      twitter:
        siteHandle: '@famhq'
        creatorHandle: '@famhq'
        title: undefined
        description: undefined
        # min 280 x 150 < 1MB
        image: 'http://cdn.wtf/d/images/fam/web_icon_1024.png'

      openGraph:
        title: undefined
        url: undefined
        description: undefined
        siteName: 'Fam'
        # min 200 x 200, min reccomended 600 x 315, reccomended 1200 x 630
        image: 'http://cdn.wtf/d/images/fam/web_icon_1024.png'

      ios:
        # min 152 x 152
        icon: undefined

      canonical: undefined
      themeColor: colors.$primary500
      # reccomended 32 x 32 png
      favicon: config.CDN_URL + '/favicon.png'
      manifestUrl: '/manifest.json'
    }, meta

    meta.title = "Clash Royale #{meta.title} | Fam"

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

    {twitter, openGraph, ios} = meta

    isInliningSource = config.ENV is config.ENVS.PROD
    webpackDevUrl = config.WEBPACK_DEV_URL
    isNative = Environment.isNativeApp(config.GAME_KEY, {userAgent})
    host = serverData?.req?.headers.host or window?.location?.host

    z 'head',
      z 'title', "#{meta.title}"
      z 'meta', {name: 'description', content: "#{meta.description}"}

      # Appcache
      # TODO: re-enable?
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
                  maximum-scale=1.0, user-scalable=0, minimal-ui,
                  viewport-fit=cover'

      z 'meta',
        'http-equiv': 'Content-Security-Policy'
        content: "default-src 'self' file://* *; style-src 'self'" +
          " 'unsafe-inline'; script-src 'self' 'unsafe-inline' 'unsafe-eval'"


      # Twitter card
      z 'meta', {name: 'twitter:card', content: 'summary_large_image'}
      z 'meta', {name: 'twitter:site', content: "#{twitter.siteHandle}"}
      z 'meta', {name: 'twitter:creator', content: "#{twitter.creatorHandle}"}
      z 'meta', {
        name: 'twitter:title'
        content: "#{twitter.title or meta.title}"
      }
      z 'meta', {
        name: 'twitter:description'
        content: "#{twitter.description or meta.description}"
      }
      z 'meta', {name: 'twitter:image', content: "#{twitter.image}"}

      # Open Graph
      z 'meta', {property: 'og:title', content: "#{openGraph.title}"}
      z 'meta', {property: 'og:type', content: 'website'}
      if openGraph.url
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
      if meta.canonical
        z 'link', {rel: 'canonical', href: "#{meta.canonical}"}
      z 'meta', {name: 'theme-color', content: "#{meta.themeColor}"}
      z 'link', {rel: 'icon', href: "#{meta.favicon}"}
      z 'meta', {name: 'msapplication-tap-highlight', content: 'no'}

      # Android
      z 'link', {rel: 'manifest', href: "#{meta.manifestUrl}"}

      # serialization
      z 'script.model',
        innerHTML: modelSerialization or ''


      # GA limits us to 10M hits per month, which we exceed by a lot...
      # so we'll sample it (10%)
      z 'script',
        innerHTML: "
          window.ga=window.ga||function(){(ga.q=ga.q||[]).push(arguments)};
          ga.l=+new Date;
          ga('create', '#{config.GOOGLE_ANALYTICS_ID}', 'auto', {
            sampleRate: 10
          });
          window.addEventListener('error', function(e) {
            ga(
              'send', 'event', 'error', e.message, e.filename + ':  ' + e.lineno
            );
          });
        "
      z 'script',
        async: true
        src: 'https://www.google-analytics.com/analytics.js'

      unless isNative
        [
          z 'script',
            async: true
            src: '//pagead2.googlesyndication.com/pagead/js/adsbygoogle.js'
        ]
      if host.indexOf('fortnitefam-es.com') isnt -1 or group?.key is 'fortnitees'
        z 'script',
          innerHTML:
            '(adsbygoogle = window.adsbygoogle || []).push({
              google_ad_client: "ca-pub-8707592103881972",
              enable_page_level_ads: true
            });'

      z 'style.rubik', rubikCss

      # styles
      z 'style',
        key: 'css-variables'
        innerHTML:
          ":root {#{cssVariables or @model.cookie.get 'cachedCssVariables'}}"
      if isInliningSource
        # we could use separate css file for styles, which would benefit from
        # cache... but we have a weird problem where chrome tries to
        # re-parse the css file resulting in a white flash. maybe a vdom issue?
        z 'style',
          type: 'text/css'
        , serverData?.styles
        # z 'link',
        #   rel: 'stylesheet'
        #   type: 'text/css'
        #   href: serverData?.bundleCssPath
      else
        null

      # scripts
      z 'script.bundle',
        async: true
        src: if isInliningSource then serverData?.bundlePath \
             else "#{webpackDevUrl}/bundle.js"

       # TODO: have these update with the router, not just on pageload
       # maybe route should do a head re-render, so it doesn'th ave to do it for
       # every render
       _map paths, (path, lang) ->
         z 'link', {
           rel: 'alternate'
           href: "https://#{config.HOST}#{path}"
           hreflang: lang
         }
