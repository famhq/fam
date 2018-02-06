z = require 'zorium'
_sortBy = require 'lodash/sortBy'
_groupBy = require 'lodash/groupBy'
RxReplaySubject = require('rxjs/ReplaySubject').ReplaySubject
RxObservable = require('rxjs/Observable').Observable
require 'rxjs/add/observable/combineLatest'

Trades = require '../../components/trades'
AppBar = require '../../components/app_bar'
ButtonMenu = require '../../components/button_menu'
Tabs = require '../../components/tabs'
Icon = require '../../components/icon'
colors = require '../../colors'

if window?
  require './index.styl'

MAX_DONE_TRADES = 25
MIN_MS_BETWEEN_REFRESH = 2000

module.exports = class TradesPage
  constructor: ({@model, @router, requests, serverData}) ->
    @$appBar = new AppBar {@model}
    @$buttonMenu = new ButtonMenu {@router, @model}

    @tradesStreams = new RxReplaySubject 1
    @tradesStreams.next @model.trade.getAll().publishReplay(1).refCount()

    meTrades = RxObservable.combineLatest(
      @model.user.getMe()
      @tradesStreams.switch()
      (vals...) -> vals
    )

    trades = meTrades.map ([me, trades]) =>
      _sortBy(trades, ({status, expireTime}) ->
        statusSort = if status is 'approved' then 2 else 1
        expireMs = if expireTime then Date.parse(expireTime) else 0
        statusSort * expireMs
      ).reverse()

      _groupBy(trades, (trade) =>
        isExpired = not trade.expireTime or
          Date.parse(trade.expireTime) < @model.time.getServerTime()

        if trade.fromId is me.id and trade.status is 'pending' and not isExpired
          'sent'
        else if trade.fromId isnt me.id and trade.status is 'pending' and
            not isExpired
          'received'
        else
          'done'
      )

    sentTrades = trades.map ({sent}) -> sent
    receivedTrades = trades.map ({received}) -> received
    doneTrades = trades.map ({done}) -> done?.splice(0, MAX_DONE_TRADES)

    @$sentTrades = new Trades {
      @model
      @router
      trades: sentTrades
    }
    @$receivedTrades = new Trades {
      @model
      @router
      trades: receivedTrades
    }
    @$doneTrades = new Trades {
      @model
      @router
      trades: doneTrades
    }

    @$tabs = new Tabs {@model, @router}
    @$addIcon = new Icon()
    @$refreshIcon = new Icon()

    @state = z.state
      isLoading: false
      lastRefreshTime: null

  getMeta: =>
    {
      title: @model.l.get 'tradesPage.title'
      description: @model.l.get 'tradesPage.title'
    }

  render: =>
    {isLoading, lastRefreshTime} = @state.getValue()

    z '.p-trades', {
      style:
        height: "#{window?.innerHeight}px"
    },
      z @$appBar,
        isFlat: true
        $topLeftButton: @$buttonMenu
        $topRightButton:
          if isLoading
            '...'
          else
            z @$refreshIcon,
              icon: 'refresh'
              color: colors.$header500Icon
              isAlignedRight: true
              onclick: =>
                now = Date.now()
                if now - lastRefreshTime < MIN_MS_BETWEEN_REFRESH
                  return

                @state.set isLoading: true, lastRefreshTime: now
                tradeUpdates = @model.trade.getAll({ignoreCache: true}).share()
                # SUPER HACKY: find a better way to do this (detect when
                # req is done loading, without an extra subscription)
                # if we pass tradeUpdates directly, since it's subscribed
                # to for sent, received, done, it gets called 3 times
                # (skipping the cache)
                tradeUpdates.take(1).toPromise().then (trades) =>
                  @state.set isLoading: false

                @tradesStreams.next tradeUpdates
        title: @model.l.get 'tradesPage.title'
      z @$tabs,
        isBarFixed: false
        hasAppBar: true
        tabs: [
          {
            $menuText: @model.l.get 'tradesPage.received'
            $el:
              z @$receivedTrades,
                $emptyStateTitle: @model.l.get 'tradesPage.receivedEmpty'
          }
          {
            $menuText: @model.l.get 'tradesPage.sent'
            $el:
              z @$sentTrades,
                $emptyStateTitle: @model.l.get 'tradesPage.sentEmpty'
          }
          {
            $menuText: @model.l.get 'tradesPage.done'
            $el:
              z @$doneTrades,
                $emptyStateTitle: @model.l.get 'tradesPage.doneEmpty'
          }
        ]
