# process.env.* is replaced at run-time with * environment variable
# Note that simply env.* is not replaced, and thus suitible for private config

_ = require 'lodash'
assertNoneMissing = require 'assert-none-missing'

colors = require './colors'

# Don't let server environment variables leak into client code
serverEnv = process.env

HOST = process.env.RED_TRITIUM_HOST or '127.0.0.1'
HOSTNAME = HOST.split(':')[0]


# All keys must have values at run-time (value may be null)
isomorphic =
  CDN_URL: 'https://cdn.wtf/d/images/red_tritium'
  IOS_APP_URL: 'https://itunes.apple.com/us/app/red-tritium/id1160535565'
  GOOGLE_PLAY_APP_URL:
    'https://play.google.com/store/apps/details?id=com.clay.redtritium'
  HOST: HOST
  GAME_KEY: 'redtritium'
  GOOGLE_ANALYTICS_ID: 'UA-27992080-30'
  STRIPE_PUBLISHABLE_KEY:
    serverEnv.STRIPE_PUBLISHABLE_KEY or
    process.env.STRIPE_PUBLISHABLE_KEY
  API_URL:
    serverEnv.PRIVATE_RADIOACTIVE_API_URL or # server
    process.env.PUBLIC_RADIOACTIVE_API_URL # client
  AUTH_COOKIE: 'accessToken'
  ENV:
    serverEnv.NODE_ENV or
    process.env.NODE_ENV
  ENVS:
    DEV: 'development'
    PROD: 'production'
    TEST: 'test'

  PLAYER_COLORS: [
    colors.$amber500
    colors.$secondary500
    colors.$primary500
    colors.$green500
    colors.$red500
    colors.$blue500
  ]
  PLAYER_AVATARS: _.map _.range(1, 40), (i) -> "#{i}00"


# Server only
# All keys must have values at run-time (value may be null)
PORT = serverEnv.RED_TRITIUM_PORT or 3000
WEBPACK_DEV_PORT = serverEnv.WEBPACK_DEV_PORT or parseInt(PORT) + 1

server =
  PORT: PORT

  # Development
  WEBPACK_DEV_PORT: WEBPACK_DEV_PORT
  WEBPACK_DEV_URL: serverEnv.WEBPACK_DEV_URL or
    "http://#{HOSTNAME}:#{WEBPACK_DEV_PORT}"
  SELENIUM_TARGET_URL: serverEnv.SELENIUM_TARGET_URL or null
  REMOTE_SELENIUM: serverEnv.REMOTE_SELENIUM is '1'
  SELENIUM_BROWSER: serverEnv.SELENIUM_BROWSER or 'chrome'
  SAUCE_USERNAME: serverEnv.SAUCE_USERNAME or null
  SAUCE_ACCESS_KEY: serverEnv.SAUCE_ACCESS_KEY or null

assertNoneMissing isomorphic
if window?
  module.exports = isomorphic
else
  assertNoneMissing server
  module.exports = _.merge isomorphic, server
