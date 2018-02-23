qs = require 'qs'
_forEach = require 'lodash/forEach'
_isEmpty = require 'lodash/isEmpty'
_defaults = require 'lodash/defaults'
_forEach = require 'lodash/forEach'
_reduce = require 'lodash/reduce'
_kebabCase = require 'lodash/kebabCase'
Environment = require '../services/environment'

SemverService = require '../services/semver'
ThemeService = require '../services/theme'
colors = require '../colors'
config = require '../config'

ev = (fn) ->
  # coffeelint: disable=missing_fat_arrows
  (e) ->
    $$el = this
    fn(e, $$el)
  # coffeelint: enable=missing_fat_arrows
isSimpleClick = (e) ->
  not (e.which > 1 or e.shiftKey or e.altKey or e.metaKey or e.ctrlKey)

class RouterService
  constructor: ({@router, @model, @cookie}) ->
    @history = []
    @onBackFn = null

  goPath: (path, {ignoreHistory, reset} = {}) =>
    unless ignoreHistory
      @history.push(path or window?.location.pathname)

    if @history[0] is '/' or @history[0] is @get('siteHome') or reset
      @history = [path]

    if path
      # store current page for app re-launch
      if Environment.isGameApp(config.GAME_KEY) and @model.cookie
        @model.cookie.set 'lastPath', path

      @router.go path

  go: (routeKey, replacements, options = {}) =>
    path = @get routeKey, replacements
    if options.qs
      @goPath "#{path}?#{qs.stringify options.qs}", options
    else
      @goPath path, options

  get: (routeKey, replacements, {language} = {}) =>
    route = @model.l.get routeKey, {file: 'paths', language}
    _forEach replacements, (value, key) ->
      route = route.replace ":#{key}", value
    route

  openLink: (url) =>
    isAbsoluteUrl = url?.match /^(?:[a-z]+:)?\/\//i
    famRegex = new RegExp "https?://(#{config.HOST}|starfire.games)", 'i'
    isFam = url?.match famRegex
    if not isAbsoluteUrl or isFam
      path = if isFam \
             then url.replace famRegex, ''
             else url
      @goPath path
    else
      @model.portal.call 'browser.openWindow', {
        url: url
        target: '_system'
      }

  back: ({fromNative, fallbackPath} = {}) =>
    if @onBackFn
      fn = @onBackFn()
      @onBack null
      return fn
    if @model.drawer.isOpen().getValue()
      return @model.drawer.close()
    if @history.length is 1 and fromNative and (
      @history[0] is '/' or @history[0] is @get 'siteHome'
    )
      @model.portal.call 'app.exit'
    else if @history.length > 1 and window.history.length > 0
      window.history.back()
      @history.pop()
    else if fallbackPath
      @goPath fallbackPath, {reset: true}
    else
      @goPath '/'

  onBack: (@onBackFn) => null

  openInAppBrowser: (addon, {replacements} = {}) =>
    if _isEmpty(addon.translatedLanguages) or
          addon.translatedLanguages.indexOf(
            @model.l.getLanguageStr()
          ) isnt -1
      language = @model.l.getLanguageStr()
    else
      language = 'en'

    replacements ?= {}
    replacements = _defaults replacements, {lang: language}
    vars = addon.url.match /\{[a-zA-Z0-9]+\}/g
    url = _reduce vars, (str, variable) ->
      key = variable.replace /\{|\}/g, ''
      str.replace variable, replacements[key] or ''
    , addon.url
    @model.portal.call 'browser.openWindow', {
      url: url
      target: '_blank'
      options:
        statusbar: {
          color: ThemeService.getVariableValue colors.$primary700
        }
        toolbar: {
          height: 56
          color: ThemeService.getVariableValue colors.$tertiary700
        }
        title: {
          color: ThemeService.getVariableValue colors.$tertiary700Text
          staticText: @model.l.get "#{addon.key}.title", {
            file: 'addons'
          }
        }
        closeButton: {
          # https://jgilfelt.github.io/AndroidAssetStudio/icons-launcher.html#foreground.type=clipart&foreground.space.trim=1&foreground.space.pad=0.5&foreground.clipart=res%2Fclipart%2Ficons%2Fnavigation_close.svg&foreColor=fff%2C0&crop=0&backgroundShape=none&backColor=fff%2C100&effects=none&elevate=0
          image: 'close'
          # imagePressed: 'close_grey'
          align: 'left'
          event: 'closePressed'
        }
    }, (data) =>
      @model.portal.portal.onMessageInAppBrowserWindow data

  openAddon: (addon, {replacements} = {}) =>
    isNative = Environment.isGameApp config.GAME_KEY
    appVersion = isNative and Environment.getAppVersion(
      config.GAME_KEY
    )
    isNewIAB = isNative and SemverService.gte appVersion, '1.4.0'
    isExternalAddon = addon.url.substr(0, 4) is 'http'
    isInAppBrowser = isNative and isNewIAB and isExternalAddon

    if not isInAppBrowser
      @go 'toolByKey', {
        key: _kebabCase(addon.key)
      }, {
        qs:
          replacements: JSON.stringify replacements
      }
    else
      @openInAppBrowser addon, {replacements}

  getStream: =>
    @router.getStream()

  link: (node) =>
    node.properties.onclick = ev (e, $$el) =>
      if isSimpleClick e
        e.preventDefault()
        @openLink $$el.href

    return node


module.exports = RouterService
