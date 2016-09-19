# process.env.* is replaced at run-time with * environment variable
# Note that simply env.* is not replaced, and thus suitible for private config

_ = require 'lodash'
assertNoneMissing = require 'assert-none-missing'

# Don't let server environment variables leak into client code
serverEnv = process.env

# All keys must have values at run-time (value may be null)
isomorphic =
  HOST: process.env.HOST or '127.0.0.1'
  API_URL:
    serverEnv.PRIVATE_API_URL or # server
    process.env.API_URL or # client
    'http://127.0.0.1:3005' # default
  AUTH_COOKIE: 'accessToken'
  ENV:
    serverEnv.NODE_ENV or
    process.env.NODE_ENV
  ENVS:
    DEV: 'development'
    PROD: 'production'
    TEST: 'test'

# Server only
# All keys must have values at run-time (value may be null)
PORT = serverEnv.PORT or 3000
WEBPACK_DEV_PORT = serverEnv.WEBPACK_DEV_PORT or parseInt(PORT) + 1

server =
  PORT: PORT

  # Development
  WEBPACK_DEV_PORT: WEBPACK_DEV_PORT
  WEBPACK_DEV_URL: serverEnv.WEBPACK_DEV_URL or
    "http://127.0.0.1:#{WEBPACK_DEV_PORT}"
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
