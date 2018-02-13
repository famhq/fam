# process.env.* is replaced at run-time with * environment variable
# Note that simply env.* is not replaced, and thus suitible for private config

_map = require 'lodash/map'
_range = require 'lodash/range'
_merge = require 'lodash/merge'
assertNoneMissing = require 'assert-none-missing'

colors = require './colors'

# Don't let server environment variables leak into client code
serverEnv = process.env

HOST = process.env.STARFIRE_HOST or '127.0.0.1'
HOSTNAME = HOST.split(':')[0]

URL_REGEX_STR = '(\\bhttps?://[-A-Z0-9+&@#/%?=~_|!:,.;]*[A-Z0-9+&@#/%=~_|])'
STICKER_REGEX_STR = '(:[a-z_]+:)'
IMAGE_REGEX_STR = '(\\!\\[(.*?)\\]\\((.*?)\\=([0-9.]+)x([0-9.]+)\\))'
IMAGE_REGEX_BASE_STR = '(\\!\\[(?:.*?)\\]\\((?:.*?)\\))'
LOCAL_IMAGE_REGEX_STR =
  '(\\!\\[(.*?)\\]\\(local://(.*?) \\=([0-9.]+)x([0-9.]+)\\))'
MENTION_REGEX_STR = '\\@[a-zA-Z0-9-]+'

ONE_HOUR_SECONDS = 3600 * 1
TWO_HOURS_SECONDS = 3600 * 2
THREE_HOURS_SECONDS = 3600 * 3
FOUR_HOURS_SECONDS = 3600 * 4
EIGHT_HOURS_SECONDS = 3600 * 8
ONE_DAY_SECONDS = 3600 * 24 * 1
TWO_DAYS_SECONDS = 3600 * 24 * 2
THREE_DAYS_SECONDS = 3600 * 24 * 3

API_URL =
  serverEnv.RADIOACTIVE_API_URL or # server
  process.env.PUBLIC_RADIOACTIVE_API_URL # client

DEV_USE_HTTPS = process.env.DEV_USE_HTTPS and process.env.DEV_USE_HTTPS isnt '0'

isUrl = API_URL.indexOf('/') isnt -1
if isUrl
  API_HOST_ARRAY = API_URL.split('/')
  API_HOST = API_HOST_ARRAY[0] + '//' + API_HOST_ARRAY[2]
  API_PATH = API_URL.replace API_HOST, ''
else
  API_HOST = API_URL
  API_PATH = ''
# All keys must have values at run-time (value may be null)
isomorphic =
  DEFAULT_GAME_KEY: 'clash-royale'
  COMMUNITY_LANGUAGES: ['es', 'pt', 'pl']
  LANGUAGES: [
    'en', 'es', 'it', 'fr', 'zh', 'ja', 'ko', 'de', 'pt', 'pl'
    'ru', 'id', 'tl', 'tr'
  ]
  # also in radioactive
  ITEM_LEVEL_REQUIREMENTS: [
    {level: 3, countRequired: 100}
    {level: 2, countRequired: 10}
    {level: 1, countRequired: 0}
  ]
  # also in radioactive TODO: shared config file
  # keep reversed for fast lookup
  XP_LEVEL_REQUIREMENTS: [
    {level: 12, xpRequired: 60000}
    {level: 11, xpRequired: 30000}
    {level: 10, xpRequired: 10000}
    {level: 9, xpRequired: 5000}
    {level: 8, xpRequired: 2000}
    {level: 7, xpRequired: 1000}
    {level: 6, xpRequired: 500}
    {level: 5, xpRequired: 200}
    {level: 4, xpRequired: 100}
    {level: 3, xpRequired: 50}
    {level: 2, xpRequired: 20}
    {level: 1, xpRequired: 0}
  ]
  XP_LEVEL_COLORS:
    1: 'blue'
    2: 'cyan'
    3: 'teal'
    4: 'green'
    5: 'lightGreen'
    6: 'lime'
    7: 'yellow'
    8: 'red'
    9: 'pink'
    10: 'purple'
    11: 'deepPurple'
    12: 'indigo'
    13: 'orange'
    # 1: 'rgb(126, 143, 234)'
    # 2: 'rgb(126, 171, 234)'
    # 3: 'rgb(126, 199, 234)'
    # 4: 'rgb(126, 234, 230)'
    # 5: 'rgb(126, 234, 190)'
    # 6: 'rgb(126, 234, 142)'
    # 7: 'rgb(178, 234, 126)'
    # 8: 'rgb(223, 234, 126)'
    # 9: 'rgb(234, 210, 126)'
    # 10: 'rgb(234, 169, 126)'
    # 11: 'rgb(234, 126, 126)'
    # 12: 'rgb(234, 126, 165)'
    # 13: 'rgb(234, 126, 194)'

  # ALSO IN RADIOACTIVE
  DEFAULT_PERMISSIONS:
    readMessage: true
    manageChannel: false
    sendMessage: true
    sendLink: true
    sendImage: true
    sendAddon: true
    bypassSlowMode: false
  DEFAULT_NOTIFICATIONS:
    chatMessage: true
    chatMention: true
  CDN_URL: 'https://cdn.wtf/d/images/starfire'
  # d folder has longer cache
  SCRIPTS_CDN_URL: 'https://cdn.wtf/d/scripts/starfire'
  USER_CDN_URL: 'https://cdn.wtf/images/starfire'
  IOS_APP_URL: 'https://itunes.apple.com/us/app/starfire/id1160535565'
  GOOGLE_PLAY_APP_URL:
    'https://play.google.com/store/apps/details?id=com.clay.redtritium'
  HOST: HOST
  GAME_KEY: 'starfire'
  GOOGLE_ANALYTICS_ID: 'UA-27992080-30'
  STRIPE_PUBLISHABLE_KEY:
    serverEnv.STRIPE_PUBLISHABLE_KEY or
    process.env.STRIPE_PUBLISHABLE_KEY
  GIPHY_API_KEY: process.env.GIPHY_API_KEY
  FB_ID: process.env.STARFIRE_FB_ID
  API_URL: API_URL
  PUBLIC_API_URL: process.env.PUBLIC_RADIOACTIVE_API_URL
  API_HOST: API_HOST
  API_PATH: API_PATH
  VAPID_PUBLIC_KEY: process.env.RADIOACTIVE_VAPID_PUBLIC_KEY
  FIREBASE:
    API_KEY: process.env.FIREBASE_API_KEY
    AUTH_DOMAIN: process.env.FIREBASE_AUTH_DOMAIN
    DATABASE_URL: process.env.FIREBASE_DATABASE_URL
    PROJECT_ID: process.env.FIREBASE_PROJECT_ID
    MESSAGING_SENDER_ID: process.env.FIREBASE_MESSAGING_SENDER_ID
  DEV_USE_HTTPS: DEV_USE_HTTPS
  AUTH_COOKIE: 'accessToken'
  ENV:
    serverEnv.NODE_ENV or
    process.env.NODE_ENV
  ENVS:
    DEV: 'development'
    PROD: 'production'
    TEST: 'test'

  BACKGROUNDS: [
    'blue'
    'green'
    'purple'
    'red'
    'yellow'
  ]
  BADGES: _map _range(1, 95), (i) -> "#{i}"
  RARITIES: ['common', 'rare', 'epic', 'Legendary']
  RARITY_COLORS:
    starter: 'white'
    common: 'white'
    rare: 'blue'
    epic: 'purple'
    legendary: 'orange'
  CONFETTI_COLORS:
    starter: [
      [255, 255, 255]
      [230, 230, 230]
      [200, 200, 200]
      [170, 170, 170]
      [140, 140, 140]
    ]
    common: [
      [255, 255, 255]
      [230, 230, 230]
      [200, 200, 200]
      [170, 170, 170]
      [140, 140, 140]
    ]
    rare: [
      [113, 188, 242]
      [98, 185, 247]
      [66, 170, 244]
      [32, 149, 232]
      [220, 220, 220]
      [255, 255, 255]
    ]
    epic: [
      [104, 11, 132]
      [122, 31, 150]
      [143, 56, 170]
      [166, 96, 188]
      [220, 220, 220]
      [255, 255, 255]
    ]
    legendary: [
      [255, 114, 0]
      [252, 132, 35]
      [252, 147, 63]
      [255, 174, 109]
      [220, 220, 220]
      [255, 255, 255]
    ]
  PLAYER_COLORS: [
    colors.$amber500
    colors.$secondary500
    colors.$primary500
    colors.$green500
    colors.$red500
    colors.$blue500
  ]
  ARENAS:
    0: 'Training Camp'
    1: 'A1 - Goblin Stadium'
    2: 'A2 - Bone Pit'
    3: 'A3 - Barbarian Bowl'
    4: 'A4 - PEKKA\'s Playhouse'
    5: 'A5 - Spell Valley'
    6: 'A6 - Buildre\'s Workshop'
    7: 'A7 - Royal Arena'
    8: 'A8 - Frozen Peak'
    9: 'A9 - Jungle Arena'
    10: 'A10 - Hog Mountain'
    11: 'A11 - Legendary Arena'
  # also in radioactive
  STICKERS: ['angry', 'crying', 'laughing', 'thumbs_up']

  STICKER_REGEX_STR: STICKER_REGEX_STR
  STICKER_REGEX: new RegExp STICKER_REGEX_STR, 'g'
  URL_REGEX_STR: URL_REGEX_STR
  URL_REGEX: new RegExp URL_REGEX_STR, 'gi'
  LOCAL_IMAGE_REGEX_STR: LOCAL_IMAGE_REGEX_STR
  IMAGE_REGEX_BASE_STR: IMAGE_REGEX_BASE_STR
  IMAGE_REGEX_STR: IMAGE_REGEX_STR
  IMAGE_REGEX: new RegExp IMAGE_REGEX_STR, 'gi'
  MENTION_REGEX: new RegExp MENTION_REGEX_STR, 'gi'

  EVENT_DURATIONS:
    "#{ONE_HOUR_SECONDS}": '1 hour'
    "#{TWO_HOURS_SECONDS}": '2 hours'
    "#{THREE_HOURS_SECONDS}": '3 hours'
    "#{FOUR_HOURS_SECONDS}": '4 hours'
    "#{EIGHT_HOURS_SECONDS}": '8 hours'
    "#{ONE_DAY_SECONDS}": '1 day'
    "#{TWO_DAYS_SECONDS}": '2 days'
    "#{THREE_DAYS_SECONDS}": '3 days'

# Server only
# All keys must have values at run-time (value may be null)
PORT = serverEnv.STARFIRE_PORT or 3000
WEBPACK_DEV_PORT = serverEnv.WEBPACK_DEV_PORT or parseInt(PORT) + 1
WEBPACK_DEV_PROTOCOL = if DEV_USE_HTTPS then 'https://' else 'http://'

server =
  PORT: PORT

  # Development
  WEBPACK_DEV_PORT: WEBPACK_DEV_PORT
  WEBPACK_DEV_PROTOCOL: WEBPACK_DEV_PROTOCOL
  WEBPACK_DEV_URL: serverEnv.WEBPACK_DEV_URL or
    "#{WEBPACK_DEV_PROTOCOL}#{HOSTNAME}:#{WEBPACK_DEV_PORT}"
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
  module.exports = _merge isomorphic, server
