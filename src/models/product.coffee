Rx = require 'rxjs'

module.exports = class Product
  constructor: ({@auth}) ->
    @allCached = new Rx.ReplaySubject 1

  getAll: ({itemId, key} = {}) =>
    @auth.stream "#{PATH}/products"

  setAllCached: (allCached) => @allCached.next allCached

  getAllCached: =>
    @allCached
