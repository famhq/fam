module.exports = class Product
  constructor: ({@auth}) ->
    @allCached = new Rx.ReplaySubject 1

  getAll: ({itemId, key} = {}) =>
    @auth.stream "#{PATH}/products"

  setAllCached: (allCached) => @allCached.onNext allCached

  getAllCached: =>
    @allCached
