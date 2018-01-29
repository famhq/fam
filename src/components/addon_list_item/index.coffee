z = require 'zorium'
Environment = require 'clay-environment'
_isEmpty = require 'lodash/isEmpty'
_defaults = require 'lodash/defaults'
_forEach = require 'lodash/forEach'
_reduce = require 'lodash/reduce'
_kebabCase = require 'lodash/kebabCase'

SemverService = require '../../services/semver'
ThemeService = require '../../services/theme'
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class AddonListItem
  constructor: ({@model, @router, addon}) ->
    @state = z.state
      addon: addon

  openInAppBrowser: (addon, {replacements} = {}) =>
    if _isEmpty(addon.translatedLanguages) or
          addon.translatedLanguages.indexOf(
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
      options:
        statusbar: {
          color: ThemeService.getVariableValue colors.$primary700
        }
        toolbar: {
          height: 56
          color: ThemeService.getVariableValue colors.$tertiary700
        }
        title: {
          color: ThemeService.getVariableValue colors.$tertiary700Text
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

  render: ({hasPadding, replacements, onclick} = {}) =>
    hasPadding ?= true
    {addon} = @state.getValue()

    unless addon?.key
      return null

    z 'a.z-addon-list-item', {
      href: @router.get 'toolByKey', {
        key: _kebabCase(addon.key)
      }
      className: z.classKebab {hasPadding}
      onclick: (e) =>
        e?.preventDefault()

        if onclick
          onclick()
        else
          isNative = Environment.isGameApp config.GAME_KEY
          appVersion = isNative and Environment.getAppVersion(
            config.GAME_KEY
          )
          isNewIAB = isNative and SemverService.gte appVersion, '1.4.0'
          isExternalAddon = addon.url.substr(0, 4) is 'http'
          isInAppBrowser = isNative and isNewIAB and isExternalAddon

          if not isInAppBrowser
            @router.go 'toolByKey', {
              key: _kebabCase(addon.key)
            }, {
              qs:
                replacements: JSON.stringify replacements
            }
          else
            @openInAppBrowser addon, {replacements}
    },
      z '.icon-wrapper',
        z 'img.icon',
          src: addon.iconUrl
      z '.info',
        z '.name',
          @model.l.get "#{addon.key}.title", {file: 'addons'}
          z 'span.creator',
            " #{@model.l.get 'general.by'} #{addon.creator?.name}"
        z '.description',
          @model.l.get "#{addon.key}.description", {file: 'addons'}
