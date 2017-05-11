_reduce = require 'lodash/reduce'
_defaultsDeep = require 'lodash/defaultsDeep'

config = require '../config'

# missing: card_info, channel picker, edit group, edit group change badge
# events 'participants', 'begins', 'ends'
# group list 'members'
# thread points
# friendspage
# profile page share

languages =
  en: require '../lang/strings_en'
  es: require '../lang/strings_es'
  it: require '../lang/strings_it'
  fr: require '../lang/strings_fr'

class Language
  constructor: ({@language}) -> null

  setLanguage: (@language) => null

  get: (strKey, replacements) =>
    baseResponse = languages[@language]?[strKey] or ''

    unless baseResponse
      console.log 'missing', strKey

    if typeof baseResponse is 'object'
      # some languages (czech) have many plural forms
      pluralityCount = replacements[baseResponse.pluralityCheck]
      baseResponse = baseResponse.plurality[pluralityCount] or
                      baseResponse.plurality.other or ''

    _reduce replacements, (str, replace, key) ->
      find = ///__#{key}__///g
      str.replace find, replace
    , baseResponse


module.exports = Language
