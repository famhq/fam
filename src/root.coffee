require './polyfill'

_ = require 'lodash'
z = require 'zorium'
log = require 'loga'
Rx = require 'rx-lite'
cookie = require 'cookie'
StackTrace = require 'stacktrace-js'
FastClick = require 'fastclick'
LocationRouter = require 'location-router'

require './root.styl'

config = require './config'
CookieService = require './services/cookie'
RouterService = require './services/router'
App = require './app'
Model = require './models'

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
    _.map cookies, (value, key) ->
      unless currentCookies[key] is value
        document.cookie = cookie.serialize \
          key, value, CookieService.getCookieOpts()
    currentCookies = cookies

init = ->
  FastClick.attach document.body
  currentCookies = cookie.parse(document.cookie)
  cookieSubject = new Rx.BehaviorSubject currentCookies
  cookieSubject.subscribeOnNext setCookies(currentCookies)

  model = new Model({cookieSubject})
  model.portal.listen()

  router = new RouterService {
    portal: model.portal
    router: new LocationRouter()
  }

  root = document.createElement 'div'
  requests = router.getStream()
  app = new App({requests, model, router})
  $app = z app
  z.bind root, $app

  model.portal.call 'kik.isEnabled'
  .then (isKikEnabled) ->
    if isKikEnabled
      model.portal.call 'auth.kikLogin'
      .then (auth) ->
        if auth?
          model.auth.loginKik auth
  .then (path = null) ->
    router.go(path)
  .catch ->
    router.go()
  .then ->
    if model.wasCached()
      z.untilStable $app, {timeout: 200} # arbitrary
  .catch -> null
  .then ->
    requests.subscribeOnNext ({path}) ->
      if window?
        ga? 'send', 'pageview', path
        # model.hyperplane.emit 'pageview', {fields: {path: path}}
        # .catch log.error

    # nextTick prevents white flash
    setTimeout ->
      $$root = document.getElementById 'zorium-root'
      $$root.parentNode.replaceChild root, $$root

  window.addEventListener 'resize', app.onResize
  model.portal.call 'orientation.onChange', app.onResize

if document.readyState isnt 'complete' and
    not document.getElementById 'zorium-root'
  window.addEventListener 'load', init
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
