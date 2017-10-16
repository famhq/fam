_forEach = require 'lodash/forEach'

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
  constructor: ({@router, @model}) ->
    @history = []
    @onBackFn = null

  goPath: (route, {ignoreHistory, reset} = {}) =>
    unless ignoreHistory
      @history.push(route or window?.location.pathname)

    # TODO: handle for other languages...
    if route is '/' or route is '/profile' or reset
      @history = [route]

    if route
      @router.go route

  go: (routeKey, replacements, {ignoreHistory} = {}) =>
    path = @get routeKey, replacements
    @goPath path, {ignoreHistory}

  get: (routeKey, replacements) =>
    route = @model.l.get routeKey, {file: 'paths'}
    _forEach replacements, (value, key) ->
      route = route.replace ":#{key}", value
    route

  openLink: (url) =>
    isAbsoluteUrl = url?.match /^(?:[a-z]+:)?\/\//i
    starfireRegex = new RegExp "https?://(#{config.HOST}|starfi.re)", 'i'
    isStarfire = url?.match starfireRegex
    if not isAbsoluteUrl or isStarfire
      path = if isStarfire \
             then url.replace starfireRegex, ''
             else url
      @goPath path
    else
      @model.portal.call 'browser.openWindow', {
        url: url
        target: '_system'
      }

  back: ({fromNative} = {}) =>
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
    else
      @goPath '/'

  onBack: (@onBackFn) => null

  getStream: =>
    @router.getStream()

  link: (node) =>
    node.properties.onclick = ev (e, $$el) =>
      if isSimpleClick e
        e.preventDefault()
        @openLink $$el.href

    return node


module.exports = RouterService
