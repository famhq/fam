_reduce = require 'lodash/reduce'
_defaultsDeep = require 'lodash/defaultsDeep'
Rx = require 'rx-lite'
moment = require 'moment'
_mapValues = require 'lodash/mapValues'

config = require '../config'

# missing: card_info, channel picker, edit group, edit group change badge
# events 'participants', 'begins', 'ends'
# group list 'members'
# thread points
# friendspage
# profile page share

files = {strings: null, cards: null, addons: null}

files = _mapValues files, (val, file) ->
  en: require "../lang/en/#{file}_en"
  es: require "../lang/es/#{file}_es"
  it: require "../lang/it/#{file}_it"
  fr: require "../lang/fr/#{file}_fr"
  zh: require "../lang/zh/#{file}_zh"
  ja: require "../lang/ja/#{file}_ja"
  ko: require "../lang/ko/#{file}_ko"
  de: require "../lang/de/#{file}_de"
  pt: require "../lang/pt/#{file}_pt"
  pl: require "../lang/pl/#{file}_pl"

class Language
  constructor: ({language}) ->
    @language = new Rx.BehaviorSubject language
    @setLanguage language

  setLanguage: (language) =>
    @language.onNext language
    moment.locale language

    # change from 'a few seconds ago'
    justNowStr = @get 'time.justNow'

    moment.fn.fromNowModified = (a) ->
      if Math.abs(moment().diff(this)) < 30000
        # 1000 milliseconds
        return justNowStr
      @fromNow a

  getLanguage: => @language

  getLanguageStr: => @language.getValue()

  get: (strKey, {replacements, file} = {}) =>
    file ?= 'strings'
    language = @language.getValue()
    baseResponse = files[file][language]?[strKey] or
                    files[file]['en']?[strKey] or ''

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
