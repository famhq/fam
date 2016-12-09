express = require 'express'
_every = require 'lodash/every'
_values = require 'lodash/values'
_defaults = require 'lodash/defaults'
_map = require 'lodash/map'
compress = require 'compression'
log = require 'loga'
helmet = require 'helmet'
z = require 'zorium'
Promise = require 'bluebird'
request = require 'clay-request'
Rx = require 'rx-lite'
cookieParser = require 'cookie-parser'
fs = require 'fs'
socketIO = require 'socket.io-client'

config = require './src/config'
gulpPaths = require './gulp_paths'
App = require './src/app'
Model = require './src/models'
CookieService = require './src/services/cookie'
RouterService = require './src/services/router'

MIN_TIME_REQUIRED_FOR_HSTS_GOOGLE_PRELOAD_MS = 10886400000 # 18 weeks
HEALTHCHECK_TIMEOUT = 200
RENDER_TO_STRING_TIMEOUT_MS = 250
BOT_RENDER_TO_STRING_TIMEOUT_MS = 2000

styles = if config.ENV is config.ENVS.PROD
  fs.readFileSync gulpPaths.dist + '/bundle.css', 'utf-8'
else
  null

bundlePath = if config.ENV is config.ENVS.PROD
  stats = JSON.parse \
    fs.readFileSync gulpPaths.dist + '/stats.json', 'utf-8'

  # Date.now() is there because for some reason, the cache doesn't seem to get
  # cleared for some users. Hoping this helps
  "/bundle.js?#{stats.hash}#{Date.now()}"
else
  null

app = express()
app.use compress()

# CSP is disabled because kik lacks support
# frameguard header is disabled because Native app frames page
app.disable 'x-powered-by'
app.use helmet.xssFilter()
app.use helmet.hsts
  # https://hstspreload.appspot.com/
  maxAge: MIN_TIME_REQUIRED_FOR_HSTS_GOOGLE_PRELOAD_MS
  includeSubDomains: true # include in Google Chrome
  preload: true # include in Google Chrome
  force: true
app.use helmet.noSniff()
app.use cookieParser()

app.use '/healthcheck', (req, res, next) ->
  Promise.all [
    Promise.cast(request(config.API_URL + '/ping'))
      .timeout HEALTHCHECK_TIMEOUT
      .reflect()
  ]
  .spread (api) ->
    result =
      api: api.isFulfilled()

    isHealthy = _every _values result
    if isHealthy
      res.json {healthy: isHealthy}
    else
      res.status(500).json _defaults {healthy: isHealthy}, result
  .catch next

app.use '/ping', (req, res) ->
  res.send 'pong'

app.use '/setCookie', (req, res) ->
  res.statusCode = 302
  res.cookie 'first_cookie', '1', {maxAge: 3600 * 24 * 365 * 10}
  res.setHeader 'Location', decodeURIComponent req.query?.redirect_url
  res.end()

app.get '/manifest.json', (req, res, next) ->
  try
    res.setHeader 'Content-Type', 'application/json'
    res.send new Buffer(req.query.data, 'base64').toString()
  catch err
    next err

if config.ENV is config.ENVS.PROD
then app.use express.static(gulpPaths.dist, {maxAge: '4h'})
else app.use express.static(gulpPaths.build, {maxAge: '4h'})

app.use (req, res, next) ->
  hasSent = false
  setCookies = (currentCookies) ->
    (cookies) ->
      _map cookies, (value, key) ->
        if currentCookies[key] isnt value and not hasSent
          res.cookie(key, value, CookieService.getCookieOpts())
      currentCookies = cookies

  cookieSubject = new Rx.BehaviorSubject req.cookies
  cookieSubject.subscribeOnNext setCookies(req.cookies)

  router = new RouterService {
    portal: null
    router: null
  }
  io = socketIO config.API_HOST, {
    path: (config.API_PATH or '') + '/socket.io'
  }
  model = new Model({cookieSubject, io, serverHeaders: req.headers})
  requests = new Rx.BehaviorSubject(req)
  serverData = {req, res, styles, bundlePath}
  userAgent = req.headers?['user-agent']
  isFacebookCrawler = userAgent?.indexOf('facebookexternalhit') isnt -1 or
      userAgent?.indexOf('Facebot') isnt -1
  isOtherBot = userAgent?.indexOf('bot') isnt -1
  z.renderToString new App({requests, model, serverData, router}), {
    timeout: if isFacebookCrawler or isOtherBot \
             then BOT_RENDER_TO_STRING_TIMEOUT_MS
             else RENDER_TO_STRING_TIMEOUT_MS
  }
  .then (html) ->
    io.disconnect()
    hasSent = true
    res.send '<!DOCTYPE html>' + html
  .catch (err) ->
    io.disconnect()
    # console.log 'err', err
    log.error err
    if err.html
      hasSent = true
      res.send '<!DOCTYPE html>' + err.html
    else
      next err

module.exports = app
