require './polyfill'

_ = require 'lodash'
z = require 'zorium'
log = require 'loga'
Rx = require 'rx-lite'
cookie = require 'cookie'
StackTrace = require 'stacktrace-js'
FastClick = require 'fastclick'
LocationRouter = require 'location-router'
Environment = require 'clay-environment'
socketIO = require 'socket.io-client'

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

  isOffline = new Rx.BehaviorSubject false
  isBackendUnavailable = new Rx.BehaviorSubject false
  currentNotification = new Rx.BehaviorSubject false

  onOnline = ->
    isOffline.onNext false
  onOffline = ->
    isOffline.onNext true

  io = socketIO config.API_URL
  model = new Model({cookieSubject, io})
  model.portal.listen()

  router = new RouterService {
    portal: model.portal
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

  if Environment.isGameApp(config.GAME_KEY)
    model.portal.call 'networkInformation.onOffline', onOffline
    model.portal.call 'networkInformation.onOnline', onOnline
  else
    window.addEventListener 'online',  onOnline
    window.addEventListener 'offline',  onOffline


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

  model.portal.call 'top.getData'
  .then routeHandler
  .catch (err) ->
    log.error err
    router.go()
  .then ->
    model.portal.call 'app.isLoaded'
  .then ->
    model.portal.call 'top.onData', routeHandler
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

  #
  # PUSH NOTIFICATIONS
  #

  model.portal.call 'push.register'
  .then ({token} = {}) ->
    if token?
      unless localStorage?['pushTokenStored']
        model.pushToken.create {token}
        localStorage?['pushTokenStored'] = 1
      model.pushToken.setCurrentPushToken token
  .catch (err) ->
    unless err.message is 'Method not found'
      log.error err

  model.portal.call 'app.onResume', ->
    model.auth.clearNetoxCache()
    model.user.updateServerTime()
    if Environment.isiOS() and Environment.isGameApp config.GAME_KEY
      model.portal.call 'push.setBadgeNumber', {number: 0}

  model.portal.call 'app.onBack', ->
    router.back({fromNative: true})

  #
  # PAYMENTS
  #
  # consume any pending payments (eg the req to clay server failed)
  # This can't run simultaneously with getProductDetail
  # because of how IABHelper works on Android. If 2 async requests are
  # called at same time (in our case, getProduct and getPending),
  # the prev one is killed...
  # rewardPending = ->
  #   model.portal.call 'payments.getPending'
  #   .then (pendingPayments) ->
  #     Promise.all _.map pendingPayments, (payment) ->
  #       {purchaseToken, receipt, productId, packageName, price} = payment
  #       platform = if purchaseToken then 'android' else 'ios'
  #       receipt or= purchaseToken
  #       model.payment.verify {
  #         platform: platform
  #         receipt: receipt
  #         productId: productId
  #         packageName: packageName
  #         price: price
  #         isFromPending: true
  #       }
  #       .catch -> null
  #     .then (paymentVerifications) ->
  #       productIds = _.filter _.map paymentVerifications, 'productId'
  #
  #       unless _.isEmpty productIds
  #         model.portal.call 'payments.consumePurchase', {
  #           productIds: productIds
  #         }
  #   .catch (err) ->
  #     unless err.message is 'Method not found'
  #       log.error err
  #
  # rewardPending()
  # .then ->
  #   # fetch immediately so they're available right when store loads (fetching
  #   # takes a few seconds)
  #   productsObservable = model.product.getAll().flatMapLatest((apiProducts) ->
  #     if not Environment.isGameApp config.GAME_KEY
  #       return Rx.Observable.just apiProducts
  #     else
  #       productIds = _.map apiProducts, 'productId'
  #       Rx.Observable.fromPromise model.portal.call(
  #         'payments.getProductDetail', {productIds}
  #       ).then ({products}) ->
  #         products = _.filter products
  #         _.map products, (product) ->
  #           _.defaults(
  #             product, _.find(apiProducts, {productId: product.productId})
  #           )
  #   ).share()
  #   model.product.setAllCached productsObservable
  #   productsObservable.take(1).toPromise()
  # .then ->
  #   # try again in case it didn't work the first time
  #   rewardPending()


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
