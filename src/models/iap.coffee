RxReplaySubject = require('rxjs/ReplaySubject').ReplaySubject

module.exports = class Product
  namespace: 'iap'

  constructor: ({@auth}) ->
    @allCached = new RxReplaySubject 1

  getAllByPlatform: (platform) =>
    @auth.stream "#{@namespace}.getAllByPlatform", {platform}

  setAllCached: (allCached) => @allCached.next allCached

  getAllCached: =>
    @allCached
