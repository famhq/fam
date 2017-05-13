require './polyfill'

_map = require 'lodash/map'
z = require 'zorium'
log = require 'loga'
Rx = require 'rx-lite'
cookie = require 'cookie'
FastClick = require 'fastclick'
LocationRouter = require 'location-router'
Environment = require 'clay-environment'
socketIO = require 'socket.io-client'

require './root.styl'

config = require './config'
CookieService = require './services/cookie'
RouterService = require './services/router'
PushService = require './services/push'
App = require './app'
Model = require './models'
Portal = require './models/portal'

MAX_ERRORS_LOGGED = 5

###########
# LOGGING #
###########

if config.ENV is config.ENVS.PROD
  log.level = 'warn'

# Report errors to API_URL/log
errorsSent = 0
postErrToServer = (err) ->
  if errorsSent < MAX_ERRORS_LOGGED
    errorsSent += 1
    window.fetch config.API_URL + '/log',
      method: 'POST'
      headers:
        'Content-Type': 'text/plain' # Avoid CORS preflight
      body: JSON.stringify
        event: 'client_error'
        trace: null # trace
        error: String(err)
    .catch (err) ->
      console?.log 'logs post', err

log.on 'error', postErrToServer

oldOnError = window.onerror
window.onerror = (message, file, line, column, error) ->
  # if we log with `new Error` it's pretty pointless (gives error message that
  # just points to this line). if we pass the 5th argument (error), it breaks
  # on json.stringify
  # log.error error or new Error message
  err = {message, file, line, column}
  postErrToServer err

  if oldOnError
    return oldOnError arguments...

#################
# ROUTING SETUP #
#################
setCookies = (currentCookies) ->
  (cookies) ->
    _map cookies, (value, key) ->
      unless currentCookies[key] is value
        document.cookie = cookie.serialize \
          key, value, CookieService.getCookieOpts()
    currentCookies = cookies

navigator.serviceWorker?.register '/service_worker.js'
# start before dom has loaded
portal = new Portal()

init = ->
  FastClick.attach document.body
  currentCookies = cookie.parse(document.cookie)
  cookieSubject = new Rx.BehaviorSubject currentCookies
  cookieSubject.subscribeOnNext setCookies(currentCookies)

  CookieService.set(
    cookieSubject, 'resolution', "#{window.innerWidth}x#{window.innerHeight}"
  )

  isOffline = new Rx.BehaviorSubject false
  isBackendUnavailable = new Rx.BehaviorSubject false
  currentNotification = new Rx.BehaviorSubject false

  io = socketIO config.API_HOST, {
    path: (config.API_PATH or '') + '/socket.io'
    # this potentially has negative side effects. firewalls could
    # potentially block websockets, but not long polling.
    # unfortunately, session affinity on kubernetes is a complete pain.
    # behind cloudflare, it seems to unevenly distribute load.
    # the libraries for sticky websocket sessions between cpus
    # also aren't great - it's hard to get the real ip sent to
    # the backend (easy as http-forwarded-for, hard as remote address)
    # and the only library that uses forwarded-for isn't great....
    # see kaiser experiments for how to pass source ip in gke, but
    # it doesn't keep session affinity (for now?) if adding polling
    transports: ['websocket']
  }
  model = new Model({cookieSubject, io, portal})
  model.portal.listen()

  onOnline = ->
    isOffline.onNext false
    console.log 'online invalidate'
    model.exoid.invalidateAll()
  onOffline = ->
    isOffline.onNext true

  router = new RouterService {
    model: model
    router: new LocationRouter()
  }

  root = document.createElement 'div'
  requests = router.getStream()
  app = new App {
    requests
    model
    router
    isOffline
    isBackendUnavailable
    currentNotification
  }
  $app = z app
  z.bind root, $app

  window.addEventListener 'beforeinstallprompt', (e) ->
    e.preventDefault()
    model.installOverlay.setPrompt e
    return false

  model.portal.call 'networkInformation.onOffline', onOffline
  model.portal.call 'networkInformation.onOnline', onOnline

  model.portal.call 'heyzap.init', {publisherKey: config.HEYZAP_PUBLISHER_KEY}

  model.portal.call 'app.onBack', ->
    router.back({fromNative: true})

  # iOS scrolls past header
  # model.portal.call 'keyboard.disableScroll'
  # model.portal.call 'keyboard.onShow', ({keyboardHeight}) ->
  #   model.window.setKeyboardHeight keyboardHeight
  # model.portal.call 'keyboard.onHide', ->
  #   model.window.setKeyboardHeight 0

  routeHandler = (data) ->
    data ?= {}
    {path, query, source, _isPush, _original, _isDeepLink} = data

    if _isDeepLink
      return # FIXME only for fb login links

    if query?.accessToken?
      model.auth.setAccessToken query.accessToken

    if _isPush and _original?.additionalData?.foreground
      model.auth.clearNetoxCache()
      if Environment.isiOS() and Environment.isGameApp config.GAME_KEY
        model.portal.call 'push.setBadgeNumber', {number: 0}

      currentNotification.onNext {
        title: _original?.additionalData?.title or _original.title
        message: _original?.additionalData?.message or _original.message
        type: _original?.additionalData?.type
        data: {path}
      }
    else if path?
      ga? 'send', 'event', 'hit_from_share', 'hit', path
      router.go path
    else
      router.go()

    if data.logEvent
      {category, action, label} = data.logEvent
      ga? 'send', 'event', category, action, label

  model.portal.call 'top.onData', (e) ->
    routeHandler e

  start = Date.now()
  (if Environment.isGameApp config.GAME_KEY
    portal.call 'top.getData'
  else
    Promise.resolve null)
  .then routeHandler
  .catch (err) ->
    log.error err
    router.go()
  .then ->
    model.portal.call 'app.isLoaded'

    # untilStable hangs many seconds and the
    # timeout (200ms) doesn't actually work
    if model.wasCached()
      new Promise (resolve) ->
        # give time for exoid combinedStreams to resolve
        # (dataStreams are cached, combinedStreams are technically async)
        setTimeout resolve, 300
        # z.untilStable $app, {timeout: 200} # arbitrary
    else
      null
  .then ->
    requests.subscribeOnNext ({path}) ->
      if window?
        ga? 'send', 'pageview', path

    # nextTick prevents white flash
    setTimeout ->
      $$root = document.getElementById 'zorium-root'
      $$root.parentNode.replaceChild root, $$root

  # window.addEventListener 'resize', app.onResize
  # model.portal.call 'orientation.onChange', app.onResize

  PushService.init {model}
  (if Environment.isGameApp(config.GAME_KEY)
    PushService.register {model, isAlwaysCalled: true}
  else
    Promise.resolve null)
  .then ->
    model.portal.call 'app.onResume', ->
      console.log 'resume invalidate'
      model.exoid.invalidateAll()
      if Environment.isiOS() and Environment.isGameApp config.GAME_KEY
        model.portal.call 'push.setBadgeNumber', {number: 0}

if document.readyState isnt 'complete' and
    not document.getElementById 'zorium-root'
  document.addEventListener 'DOMContentLoaded', init
else
  init()

#############################
# SERVICE WORKERS           #
#############################

if location.protocol is 'https:'
  navigator.serviceWorker?.register '/service_worker.js'
  .catch log.error

#############################
# ENABLE WEBPACK HOT RELOAD #
#############################

if module.hot
  module.hot.accept()
