#!/usr/bin/env coffee
_forEach = require 'lodash/forEach'
_mapValues = require 'lodash/mapValues'
fs = require 'fs'

config = require '../src/config'
Language = require '../src/models/language'

Lang = new Language({})

languages = Lang.getAll()
urlLanguages = Lang.getAllUrlLanguages()
nonGamePages = Lang.getNonGamePages()

console.log languages

_forEach languages, (language) ->
  console.log language
  if urlLanguages.indexOf(language) is -1
    return fs.writeFileSync(
      "./src/lang/#{language}/paths_#{language}.json"
      '{}'
      'utf8'
    )

  paths = JSON.parse fs.readFileSync(
    "./src/lang/#{language}/url_paths_#{language}.json"
    'utf8'
  )
  newPaths = _mapValues paths, (langPath, langKey) ->
    path = if language is 'en' then '' else "/#{language}"
    # if nonGamePages.indexOf(langKey) is -1
    #   path += '/:gameKey'
    path += langPath.replace /\{([a-zA-Z0-9-]+)\}/g, ':$1'
  newPaths.home = '/'
  # newPaths.home = if language is 'en' \
  #                 then '/:gameKey'
  #                 else "/#{language}/:gameKey"
  newPaths.siteHome = if language is 'en' then '/' else "/#{language}"
  console.log 'write new paths'
  fs.writeFileSync(
    "./src/lang/#{language}/paths_#{language}.json"
    JSON.stringify newPaths, null, '  '
    'utf8'
  )
