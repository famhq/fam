request = require 'clay-request'
Rx = require 'rxjs'

config = require '../config'

PATH = 'https://api.giphy.com/v1/gifs'

module.exports = class Gif
  search: (query, {limit}) ->
    Rx.Observable.fromPromise request "#{PATH}/search",
      qs:
        q: query
        limit: limit
        api_key: config.GIPHY_API_KEY
