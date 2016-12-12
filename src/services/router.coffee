ev = (fn) ->
  # coffeelint: disable=missing_fat_arrows
  (e) ->
    $$el = this
    fn(e, $$el)
  # coffeelint: enable=missing_fat_arrows
isSimpleClick = (e) ->
  not (e.which > 1 or e.shiftKey or e.altKey or e.metaKey or e.ctrlKey)

class RouterService
  constructor: ({@router, @portal}) ->
    @history = []

  go: (route, {reset} = {}) =>
    @history.push(route or window?.location.pathname)
    if route is '/' or reset
      @history = [route]
    @router.go route

  back: ({fromNative} = {}) =>
    if @history.length is 1 and fromNative and (
      @history[0] is '/' or
      @history[0] is '/onboard'
    )
      @portal.call 'app.exit'
    else if @history.length > 1 and window.history.length > 0
      window.history.back()
      @history.pop()
    else
      @go '/'

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
