_reduce = require 'lodash/reduce'
_defaultsDeep = require 'lodash/defaultsDeep'
Rx = require 'rx-lite'

config = require '../config'

# missing: card_info, channel picker, edit group, edit group change badge
# events 'participants', 'begins', 'ends'
# group list 'members'
# thread points
# friendspage
# profile page share

languages =
  en: require '../lang/en/strings_en'
  es: require '../lang/es/strings_es'
  it: require '../lang/it/strings_it'
  fr: require '../lang/fr/strings_fr'
  zh: require '../lang/zh/strings_zh'
  ja: require '../lang/ja/strings_ja'
  ko: require '../lang/ko/strings_ko'
  de: require '../lang/de/strings_de'

class Language
  constructor: ({language}) ->
    @language = new Rx.BehaviorSubject language

  setLanguage: (language) =>
    @language.onNext language

  getLanguage: => @language

  get: (strKey, replacements) =>
    language = @language.getValue()
    baseResponse = languages[language]?[strKey] or
                    languages['en']?[strKey] or ''

    unless baseResponse
      console.log 'missing', strKey

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
