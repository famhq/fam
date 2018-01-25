module.exports = class AppInstallAction
  namespace: 'appInstallActions'

  constructor: ({@auth}) -> null

  get: =>
    @auth.stream "#{@namespace}.get", {}, {ignoreCache: true}

  upsert: ({path}) =>
    @auth.call "#{@namespace}.upsert", {path}, {invalidateAll: true}
