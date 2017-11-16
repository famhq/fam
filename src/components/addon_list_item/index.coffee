z = require 'zorium'
Environment = require 'clay-environment'
_isEmpty = require 'lodash/isEmpty'
_defaults = require 'lodash/defaults'
_forEach = require 'lodash/forEach'
_reduce = require 'lodash/reduce'
_kebabCase = require 'lodash/kebabCase'

SemverService = require '../../services/semver'
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class AddonListItem
  constructor: ({@model, @router, addon, gameKey}) ->
    @state = z.state
      addon: addon
      gameKey: gameKey

  render: ({hasPadding, replacements} = {}) =>
    hasPadding ?= true
    {addon, gameKey} = @state.getValue()

    unless addon?.key
      return null

    z 'a.z-addon-list-item', {
      href: @router.get 'modByKey', {
        gameKey, key: _kebabCase(addon.key)
      }
      className: z.classKebab {hasPadding}
      onclick: (e) =>
        e?.preventDefault()

        isNative = Environment.isGameApp config.GAME_KEY
        appVersion = isNative and Environment.getAppVersion(
          config.GAME_KEY
        )
        isNewIAB = isNative and SemverService.gte appVersion, '1.4.0'
        isInAppBrowser = isNative and (
          isNewIAB or addon.key isnt 'deckGenerator'
        ) and addon.url.substr(0, 4) is 'http'

        if not isInAppBrowser
          @router.go 'modByKey', {
            key: _kebabCase(addon.key), gameKey
          }, {
            qs:
              replacements: JSON.stringify replacements
          }
        else
          if _isEmpty(addon.supportedLanguages) or
                addon.supportedLanguages.indexOf(
                  @model.l.getLanguageStr()
                ) isnt -1
            language = @model.l.getLanguageStr()
          else
            language = 'en'

          replacements ?= {}
          replacements = _defaults replacements, {lang: language}
          vars = addon.url.match /\{[a-zA-Z0-9]+\}/g
          url = _reduce vars, (str, variable) ->
            key = variable.replace /\{|\}/g, ''
            str.replace variable, replacements[key] or ''
          , addon.url
          @model.portal.call 'browser.openWindow', {
            url: url
            target: '_blank'
            options: if isNewIAB
              statusbar: {
                color: colors.$primary700
              }
              toolbar: {
                height: 56
                color: colors.$tertiary700
              }
              title: {
                color: colors.$tertiary700Text
                staticText: @model.l.get "#{addon.key}.title", {
                  file: 'addons'
                }
              }
              closeButton: {
                # https://jgilfelt.github.io/AndroidAssetStudio/icons-launcher.html#foreground.type=clipart&foreground.space.trim=1&foreground.space.pad=0.5&foreground.clipart=res%2Fclipart%2Ficons%2Fnavigation_close.svg&foreColor=fff%2C0&crop=0&backgroundShape=none&backColor=fff%2C100&effects=none&elevate=0
                image: 'close'
                # imagePressed: 'close_grey'
                align: 'left'
                event: 'closePressed'
              }
          }, (data) =>
            @model.portal.portal.onMessageInAppBrowserWindow data
    },
      z 'img.icon',
        src: addon.iconUrl
      z '.info',
        z '.name',
          @model.l.get "#{addon.key}.title", {file: 'addons'}
          z 'span.creator',
            " #{@model.l.get 'general.by'} #{addon.creator?.name}"
        z '.description',
          @model.l.get "#{addon.key}.description", {file: 'addons'}
