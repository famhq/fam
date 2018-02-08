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
cookieParser = require 'cookie-parser'
fs = require 'fs'
socketIO = require 'socket.io-client'
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject
require 'rxjs/add/operator/do'
require 'rxjs/add/operator/take'
require 'rxjs/add/operator/toPromise'
require 'rxjs/add/operator/publishReplay'
require 'rxjs/add/operator/concat'

config = require './src/config'
gulpPaths = require './gulp_paths'
App = require './src/app'
Model = require './src/models'
RouterService = require './src/services/router'

MIN_TIME_REQUIRED_FOR_HSTS_GOOGLE_PRELOAD_MS = 10886400000 # 18 weeks
HEALTHCHECK_TIMEOUT = 200
RENDER_TO_STRING_TIMEOUT_MS = 1200
BOT_RENDER_TO_STRING_TIMEOUT_MS = 4500

styles = if config.ENV is config.ENVS.PROD
  fs.readFileSync gulpPaths.dist + '/bundle.css', 'utf-8'
else
  null

console.log '1'

# memwatch = require 'memwatch-next'
#
# hd = undefined
# snapshotTaken = false
# # memwatch.on 'stats', (stats) ->
# console.log 'stats:', stats
# if snapshotTaken is false
#   hd = new (memwatch.HeapDiff)
#   snapshotTaken = true
#   setTimeout ->
#     diff = hd.end()
#     console.log(JSON.stringify(diff, null, '\t'))
#   , 15000
# else
#   # diff = hd.end()
#   snapshotTaken = false
#   # console.log(JSON.stringify(diff, null, '\t'))


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

# app.get '/manifest.json', (req, res, next) ->
#   try
#     res.setHeader 'Content-Type', 'application/json'
#     res.send new Buffer(req.query.data, 'base64').toString()
#   catch err
#     next err

# legacy 301s. can remove in jan 2018
redirects =
  '/clash-royale/mod/:key': '/tool/:key'
  '/:lang/clash-royale/mod/:key': '/tool/:key'
  '/pt/clash-royale/jogador/:playerId/embutir': '/tool/clash-royale-player/:playerId'
  '/es/clash-royale/jugador/:playerId/emportar': '/tool/clash-royale-player/:playerId'
  '/clash-royale/player/:playerId/embed': '/tool/clash-royale-player/:playerId'
  '/clash-royale/user/id/:userId': '/user/id/:userId'
  '/clash-royale/user/:username': '/user/:username'
  '/:lang/clash-royale/user/id/:userId': '/user/id/:userId'
  '/:lang/clash-royale/user/:username': '/user/:username'
  '/:lang/clash-royale/*': '/g/clashroyale/*'
  '/clash-royale/*': '/g/clashroyale/*'
  '/:lang/clash-royale': '/g/clashroyale'

  # '/addons': '/clash-royale/mods'
  # '/addon': '/clash-royale/mod'
  # '/social': '/clash-royale/chat'
  # '/social/:tab': '/clash-royale/chat'
  # '/clan': '/clash-royale/clan'
  # '/profile': '/clash-royale/profile'
  # '/recruiting': '/clash-royale/recruit'
  # '/forum': '/clash-royale/forum'
  # '/clay-royale-player/:playerId': '/clash-royale/:playerId'
  # '/players': '/clash-royale/players'
  # '/player/:playerId': '/clash-royale/player/:playerId'
  # '/players/search': '/clash-royale/players/search'
  # '/user/:id': '/clash-royale/user/:id'
  # '/conversation/:id': '/clash-royale/conversation/:id'
  # '/thread/*': '/clash-royale/thread/*'
  # # '/group/*': '/clash-royale/group/*'
  # # '/user/id/:id/chests': '/clash-royale/chest-cycle/:id' # userId != playerId
  # '/player/:playerId/chests': '/clash-royale/chest-cycle/:playerId'

_map redirects, (newPath, oldPath) ->
  app.use oldPath, (req, res) ->
    goPath = newPath
    _map req.params, (value, key) ->
      goPath = goPath.replace ":#{key}", value
      oldPath = oldPath.replace ":#{key}", value

    if oldPath.indexOf('*') isnt -1
      oldPathRegex = new RegExp oldPath.replace('*', '(.*?)$')
      matches = oldPathRegex.exec req.originalUrl
      if matches
        goPath = goPath.replace '*', matches[1]
      else
        goPath = '/'
    # FIXME: 301
    res.redirect 302, goPath

# end legacy

if config.ENV is config.ENVS.PROD
then app.use express.static(gulpPaths.dist, {maxAge: '4h'})
else app.use express.static(gulpPaths.build, {maxAge: '4h'})

stats = JSON.parse \
  fs.readFileSync gulpPaths.dist + '/stats.json', 'utf-8'

app.use (req, res, next) ->
  # migrate to starfire.games
  # check if native app
  userAgent = req.headers['user-agent']
  host = req.headers.host
  accessToken = req.query.accessToken
  isNativeApp = userAgent?.indexOf('starfire') isnt -1
  isBot = /bot|crawler|spider|crawling/i.test(userAgent)
  isLegacyHost = host.indexOf('starfi.re') isnt -1 or
                  host.indexOf('redtritium.com') isnt -1

  if isLegacyHost and req.cookies?.accessToken and not isBot# and not isNativeApp
    return res.redirect(
      301
      'https://starfire.games' + req.path +
        '?accessToken=' + req.cookies?.accessToken
    )
  else if isLegacyHost# and not isNativeApp
    return res.redirect(301, 'https://starfire.games' + req.path)
  else if accessToken and not isLegacyHost# and not isNativeApp
    res.cookie(
      'accessToken'
      accessToken
      {
        path: '/'
        expires: new Date(Date.now() + 3600 * 24 * 365)
        domain: '.' + host.split(':')[0]
      }
    )
    return res.redirect(301, 'https://starfire.games' + req.path)
  # end migrate

  hasSent = false

  cookieSubject = new RxBehaviorSubject req.cookies

  io = socketIO config.API_HOST, {
    path: (config.API_PATH or '') + '/socket.io'
    timeout: 5000
    transports: ['websocket']
  }
  fullLanguage = req.headers?['accept-language']
  language = req.cookies?['language'] or fullLanguage?.substr(0, 2)
  unless language in config.LANGUAGES
    language = 'en'
  model = new Model {
    cookieSubject, io, serverHeaders: req.headers, language
  }
  router = new RouterService {
    router: null
    model: model
  }
  requests = new RxBehaviorSubject(req)

  setCookies = (currentCookies) ->
    (cookies) ->
      _map cookies, (value, key) ->
        if currentCookies[key] isnt value and not hasSent
          res.cookie(key, value, model.cookie.getCookieOpts(host))
      currentCookies = cookies
  disposable = cookieSubject.do(setCookies(req.cookies)).subscribe()

  # for client to access
  model.cookie.set(
    'ip'
    req.headers?['x-forwarded-for'] or req.connection.remoteAddress
  )

  if config.ENV is config.ENVS.PROD
    scriptsCdnUrl = config.SCRIPTS_CDN_URL
    bundlePath = "#{scriptsCdnUrl}/bundle_#{stats.hash}_#{language}.js"
    bundleCssPath = "/bundle.css?#{stats.time}"
  else
    bundlePath = null
    bundleCssPath = null

  serverData = {req, res, bundlePath, bundleCssPath, styles}
  userAgent = req.headers?['user-agent']
  isFacebookCrawler = userAgent?.indexOf('facebookexternalhit') isnt -1 or
      userAgent?.indexOf('Facebot') isnt -1
  isOtherBot = userAgent?.indexOf('bot') isnt -1
  start = Date.now()
  z.renderToString new App({requests, model, serverData, router}), {
    timeout: if isFacebookCrawler or isOtherBot \
             then BOT_RENDER_TO_STRING_TIMEOUT_MS
             else RENDER_TO_STRING_TIMEOUT_MS
  }
  .then (html) ->
    io.disconnect()
    model.dispose()
    disposable.unsubscribe()
    disposable = null
    hasSent = true
    # TODO: not sure why, but some paths (eg /g/clashroyale/somerandompage)
    # send back before head exists
    if html.indexOf('<head>') is -1
      res.redirect 302, '/'
    else
      res.send '<!DOCTYPE html>' + html
  .catch (err) ->
    io.disconnect()
    model.dispose()
    disposable?.unsubscribe()
    log.error err
    if err.html
      hasSent = true
      if err.html.indexOf('<head>') is -1
        res.redirect 302, '/'
      else
        res.send '<!DOCTYPE html>' + err.html
    else
      next err

module.exports = app
