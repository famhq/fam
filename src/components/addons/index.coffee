z = require 'zorium'
Rx = require 'rx-lite'
semver = require 'semver'
Environment = require 'clay-environment'
_isEmpty = require 'lodash/isEmpty'
_map = require 'lodash/map'
_truncate = require 'lodash/truncate'
_kebabCase = require 'lodash/kebabCase'

Base = require '../base'
Avatar = require '../avatar'
Icon = require '../icon'
Spinner = require '../spinner'
FormatService = require '../../services/format'
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

MAX_TITLE_LENGTH = 60

module.exports = class Addons extends Base
  constructor: ({@model, @router, sort, filter}) ->
    @$spinner = new Spinner()

    me = @model.user.getMe()
    addons = @model.addon.getAll({sort, filter})
    # streams = @model.stream.getAll({sort, filter})

    @state = z.state
      me: @model.user.getMe()
      addons: addons.map (addons) ->
        _map addons, (addon) ->
          {
            addon
            $rating: null # TODO
          }

  render: =>
    {me, addons} = @state.getValue()

    z '.z-addons',
      z 'h2.title', @model.l.get 'addons.discover'
      z '.addons',
        if addons and _isEmpty addons
          'No addons found'
        else if addons
          _map addons, ({addon, $rating}) =>
            [
              z 'a.addon', {
                href: "/addon/clash-royale/#{_kebabCase(addon.key)}"
                onclick: (e) =>
                  e?.preventDefault()

                  isNative = Environment.isGameApp config.GAME_KEY
                  appVersion = isNative and Environment.getAppVersion(
                    config.GAME_KEY
                  )
                  isNewIAB = isNative and semver.gte appVersion, '1.4.0'
                  isInAppBrowser = isNative and (
                    isNewIAB or addon.key isnt 'deckGenerator'
                  ) and addon.url.substr(0, 4) is 'http'

                  if not isInAppBrowser
                    @router.go "/addon/clash-royale/#{_kebabCase(addon.key)}"
                  else
                    @model.portal.call 'browser.openWindow', {
                      url: addon.url
                      options: if isNewIAB
                        statusbar: {
                          color: '#ffffffff'
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
                      " #{@model.l.get 'general.by'} #{addon.creator.name}"
                  z '.description',
                    @model.l.get "#{addon.key}.description", {file: 'addons'}
            ]
        else
          @$spinner
