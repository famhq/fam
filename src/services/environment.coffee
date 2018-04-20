_includes = require 'lodash/includes'

config = require '../config'

class Environment
  isMobile: ({userAgent} = {}) ->
    userAgent ?= navigator?.userAgent
    ///
      Mobile
    | iP(hone|od|ad)
    | Android
    | BlackBerry
    | IEMobile
    | Kindle
    | NetFront
    | Silk-Accelerated
    | (hpw|web)OS
    | Fennec
    | Minimo
    | Opera\ M(obi|ini)
    | Blazer
    | Dolfin
    | Dolphin
    | Skyfire
    | Zune
    ///.test userAgent

  isFacebook: ->
    window? and window.name.indexOf('canvas_fb') isnt -1

  isAndroid: ({userAgent} = {}) ->
    userAgent ?= navigator?.userAgent
    _includes userAgent, 'Android'

  isiOS: ({userAgent} = {}) ->
    userAgent ?= navigator?.userAgent
    Boolean userAgent.match /iP(hone|od|ad)/g

  isNativeApp: (gameKey, {userAgent} = {}) ->
    userAgent ?= navigator?.userAgent
    Boolean gameKey and
      _includes(userAgent?.toLowerCase(), " #{gameKey}/") or
        _includes(userAgent?.toLowerCase(), ' starfire/') # legacy

  isMainApp: (gameKey, {userAgent} = {}) ->
    userAgent ?= navigator?.userAgent
    Boolean gameKey and
      _includes(userAgent?.toLowerCase(), " #{gameKey}/#{gameKey}")

  isGroupApp: (groupAppKey, {userAgent} = {}) ->
    userAgent ?= navigator?.userAgent
    Boolean groupAppKey and
      _includes(userAgent?.toLowerCase(), " openfam/#{groupAppKey}/")

  getAppKey: ({userAgent} = {}) ->
    userAgent ?= navigator?.userAgent
    matches = userAgent.match /openfam\/([a-zA-Z0-9-]+)/
    matches?[1] or 'browser'

  getAppVersion: (gameKey, {userAgent} = {}) ->
    userAgent ?= navigator?.userAgent
    regex = new RegExp("(#{gameKey}|starfire)\/(?:[a-zA-Z0-9]+/)?([0-9\.]+)")
    matches = userAgent.match(regex)
    matches?[2]

  getPlatform: ({gameKey, userAgent} = {}) =>
    gameKey ?= config.GAME_KEY
    userAgent ?= navigator?.userAgent

    isApp = @isNativeApp gameKey, {userAgent}

    if @isFacebook() then 'facebook'
    else if isApp and @isiOS(gameKey, {userAgent}) then 'ios'
    else if isApp and @isAndroid({userAgent}) then 'android'
    else 'web'

module.exports = new Environment()
