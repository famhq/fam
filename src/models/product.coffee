RxReplaySubject = require('rxjs/ReplaySubject').ReplaySubject

module.exports = class Product
  namespace: 'products'

  constructor: ({@auth}) ->
    @allCached = new RxReplaySubject 1

  getAll: =>
    @auth.stream "#{@namespace}.products"

  setAllCached: (allCached) => @allCached.next allCached

  getAllCached: =>
    @allCached

  buy: (options) =>
    @auth.call "#{@namespace}.buy", options, {invalidateAll: true}
