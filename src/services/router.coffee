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

  go: (route, {ignoreHistory, reset} = {}) =>
    unless ignoreHistory
      @history.push(route or window?.location.pathname)

    if route is '/' or route is '/profile' or reset
      @history = [route]

    if route
      @router.go route

  openLink: (url) =>
    isAbsoluteUrl = url?.match /^(?:[a-z]+:)?\/\//i
    starfireRegex = new RegExp "https?://#{config.HOST}", 'i'
    isStarfire = url?.match starfireRegex
    if not isAbsoluteUrl or isStarfire
      path = if isStarfire \
             then url.replace starfireRegex, ''
             else url
      @go path
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
      @history[0] is '/' or
      @history[0] is '/profile'
    )
      @model.portal.call 'app.exit'
    else if @history.length > 1 and window.history.length > 0
      window.history.back()
      @history.pop()
    else
      @go '/profile'

  onBack: (@onBackFn) => null

  getStream: =>
    @router.getStream()

  link: (node) =>
    node.properties.onclick = ev (e, $$el) =>
      isLocal = $$el.hostname is window.location.hostname

      if isLocal and isSimpleClick e
        e.preventDefault()
        @go $$el.pathname + $$el.search

    return node


module.exports = RouterService
