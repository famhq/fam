z = require 'zorium'
RxObservable = require('rxjs/Observable').Observable

Head = require '../../components/head'
Trade = require '../../components/trade'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class TradePage
  constructor: ({requests, @model, router, serverData}) ->
    tradeId = requests.map ({route}) ->
      route.params.id

    toId = requests.map ({route}) ->
      route.params.toId

    trade = tradeId.switchMap (tradeId) =>
      if tradeId
        @model.trade.getById tradeId
        .catch (err) ->
          RxObservable.of {error: 'This trade doesn\'t exist anymore!'}
      else
        RxObservable.of null

    @$trade = new Trade {
      @model
      router
      trade
    }


  getMeta: =>
    meta:
      title: @model.l.get 'tradePage.title'

  render: =>
    z '.p-trade', {
      style:
        height: "#{window?.innerHeight}px"
    },
      @$trade
