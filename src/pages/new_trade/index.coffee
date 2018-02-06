z = require 'zorium'
RxObservable = require('rxjs/Observable').Observable

NewTrade = require '../../components/new_trade'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class NewTradePage
  constructor: ({requests, @model, serverData, router, group}) ->
    tradeId = requests.map ({route}) ->
      route.params.id

    sendItem = requests.switchMap ({route}) =>
      if route.params.sendItemKey
        @model.item.getByKey route.params.sendItemKey
      else
        RxObservable.of null

    receiveItem = requests.switchMap ({route}) =>
      if route.params.receiveItemKey
        @model.item.getByKey route.params.receiveItemKey
      else
        RxObservable.of null

    sendItem = requests.switchMap ({route}) =>
      if route.params.sendItemKey
        @model.item.getByKey route.params.sendItemKey
      else
        RxObservable.of null

    toId = requests.map ({route}) ->
      route.params.toId

    counterTradeId = requests.map ({route}) ->
      route.params.counterTradeId

    @$newTrade = new NewTrade {
      @model
      router
      sendItem
      receiveItem
      sendItem
      toId
      counterTradeId
      group
      trade: tradeId.switchMap (tradeId) =>
        if tradeId
          @model.trade.getById tradeId
        else
          RxObservable.of null
    }

    @state = z.state
      sendItem: sendItem
      receiveItem: receiveItem

  getMeta: =>
    meta:
      title: @model.l.get 'newTradePage.title'
      description: @model.l.get 'newTradePage.title'

  render: =>

    z '.p-trade', {
      style:
        height: "#{window?.innerHeight}px"
    },
      @$newTrade
