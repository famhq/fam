_reduce = require 'lodash/reduce'
_defaultsDeep = require 'lodash/defaultsDeep'
moment = require 'moment'
_mapValues = require 'lodash/mapValues'
_keys = require 'lodash/keys'
_reduce = require 'lodash/reduce'
_findKey = require 'lodash/findKey'
_filter = require 'lodash/filter'
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject

CookieService = require '../services/cookie'
config = require '../config'

# missing: card_info, channel picker, edit group, edit group change badge
# events 'participants', 'begins', 'ends'
# group list 'members'
# thread points
# friendspage
# profile page share


relativeTimeFormats =
  en:
    future: 'in %s'
    past: '%s'
    s: '1s'
    ss: '%ss'
    m: '1m'
    mm: '%dm'
    h: '1h'
    hh: '%dh'
    d: '1d'
    dd: '%dd'
    M: '1M'
    MM: '%dM'
    y: '1Y'
    yy: '%dY'
  es:
    future: 'in %s'
    past: '%s'
    s: '1s'
    ss: '%ss'
    m: '1m'
    mm: '%dm'
    h: '1h'
    hh: '%dh'
    d: '1d'
    dd: '%dd'
    M: '1S'
    MM: '%dS'
    y: '1A'
    yy: '%dA'

# FIXME: change language

class Language
  constructor: ({language, @cookieSubject}) ->
    @language = new RxBehaviorSubject language

    # also update gulpfile ContextReplacementPlugin for moment
    if window?
      # done like this so compile time is quicker
      @files = window.languageStrings
    else
      files = {
        strings: null
        cards: null
        addons: null
        paths: null
        languages: null
        items: null
      }

      @files = _mapValues files, (val, file) ->
        _reduce config.LANGUAGES, (obj, lang) ->
          obj[lang] = try require "../lang/#{lang}/#{file}_#{lang}.json" \
                      catch e then null
          obj
        , {}

    @setLanguage language

  setLanguage: (language) =>
    @language.next language
    CookieService.set(
      @cookieSubject, 'language', language
    )
    relativeTime = relativeTimeFormats[language]
    moment.locale language, if relativeTime then {relativeTime} else undefined

    # change from 'a few seconds ago'
    justNowStr = @get 'time.justNow'

    moment.fn.fromNowModified = (a) ->
      if Math.abs(moment().diff(this)) < 30000
        # 1000 milliseconds
        return justNowStr
      @fromNow a

  getLanguage: => @language

  getLanguageStr: => @language.getValue()

  getAll: ->
    config.LANGUAGES

  getAllUrlLanguages: ->
    ['en', 'es', 'pt']

  # some of this would probably make more sense in router...
  getNonGamePages: ->
    [
      'policies', 'privacy', 'termsOfService'
    ]

  getRouteKeyByValue: (routeValue) =>
    language = @getLanguageStr()
    _findKey(@files['paths'][language], (route) ->
      route is routeValue) or _findKey(@files['paths']['en'], (route) ->
        route is routeValue)

  getAllPathsByRouteKey: (routeKey, isGamePath) =>
    languages = @getAllUrlLanguages()
    _reduce languages, (paths, language) =>
      path = @files['paths'][language]?[routeKey]
      if path
        paths[language] = path
      paths
    , {}

  get: (strKey, {replacements, file} = {}) =>
    file ?= 'strings'
    language = @getLanguageStr()
    baseResponse = @files[file]?[strKey] or
                    @files[file]['en']?[strKey] or ''

    unless baseResponse
      console.log 'missing', file, strKey

    if typeof baseResponse is 'object'
      # some languages (czech) have many plural forms
      pluralityCount = replacements[baseResponse.pluralityCheck]
      baseResponse = baseResponse.plurality[pluralityCount] or
                      baseResponse.plurality.other or ''

    _reduce replacements, (str, replace, key) ->
      find = ///{#{key}}///g
      str.replace find, replace
    , baseResponse


module.exports = Language
